Feature: split a module into a different application with a new version

  # This test verifies that mod-moved can be moved from one application to a differently named application when its version
  # is incremented. The original application version, its newer version, and the split application can then coexist in the
  # same FOLIO environment.
  #
  # Initial entitlement state: app-foo-1.0.0
  # - mod-moved-1.2.3
  # - mod-retained-1.1.0
  #
  # Target entitlement state: app-foo-2.0.0
  # - mod-retained-1.1.0
  #
  # Target entitlement state: app-foo-split-1.0.0
  # - mod-moved-1.3.0 (version incremented)
  # - mod-split-only-1.0.0
  #
  # These dummy module descriptors verify application and entitlement validation only; they do not test runtime API
  # or Kafka routing.
  # The test tenant also remains entitled to app-platform-minimal so mod-roles-keycloak can process and confirm the
  # capability events emitted for the fake modules.

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * def keycloakResponse = callonce read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def masterToken = keycloakResponse.response.access_token
    * def uniqueSuffix = nowMillis()
    * def appPlatformMinimal = 'app-platform-minimal'

    * def applicationName = 'it-app-foo-' + uniqueSuffix
    * def applicationV1Version = '1.0.0'
    * def applicationV2Version = '2.0.0'
    * def applicationV1Id = applicationName + '-' + applicationV1Version
    * def applicationV2Id = applicationName + '-' + applicationV2Version

    * def splitApplicationVersion = '1.0.0'
    * def splitApplicationName = 'it-app-foo-split-' + uniqueSuffix
    * def splitApplicationId = splitApplicationName + '-' + splitApplicationVersion

    * def movedModuleName = 'it-mod-moved-' + uniqueSuffix
    * def movedModuleVersion = '1.2.3'
    * def movedModuleId = movedModuleName + '-' + movedModuleVersion
    * def movedModuleLocation = 'http://' + movedModuleName + ':8080'

    * def newerMovedModuleVersion = '1.3.0'
    * def newerMovedModuleId = movedModuleName + '-' + newerMovedModuleVersion
    * def newerMovedModuleLocation = 'http://' + movedModuleName + '-newer:8080'

    * def retainedModuleName = 'it-mod-retained-' + uniqueSuffix
    * def retainedModuleVersion = '1.1.0'
    * def retainedModuleId = retainedModuleName + '-' + retainedModuleVersion
    * def retainedModuleLocation = 'http://' + retainedModuleName + ':8080'

    * def splitOnlyModuleName = 'it-mod-split-only-' + uniqueSuffix
    * def splitOnlyModuleVersion = '1.0.0'
    * def splitOnlyModuleId = splitOnlyModuleName + '-' + splitOnlyModuleVersion
    * def splitOnlyModuleLocation = 'http://' + splitOnlyModuleName + ':8080'

    * def tenantId = uuid()
    * def tenantName = 'splitapp' + uniqueSuffix
    * def terminalFlowStatuses = ['finished', 'cancelled', 'cancellation_failed', 'failed']

  @Positive
  Scenario: move a module to a differently named application with a new version
    # Step 1: Register app-foo-1.0.0 with mod-moved-1.2.3 and mod-retained-1.1.0.
    * def applicationV1 =
      """
      {
        "name": "#(applicationName)",
        "version": "#(applicationV1Version)",
        "modules": [
          { "id": "#(movedModuleId)", "name": "#(movedModuleName)", "version": "#(movedModuleVersion)" },
          { "id": "#(retainedModuleId)", "name": "#(retainedModuleName)", "version": "#(retainedModuleVersion)" }
        ],
        "moduleDescriptors": [
          { "id": "#(movedModuleId)", "name": "#(movedModuleName)" },
          { "id": "#(retainedModuleId)", "name": "#(retainedModuleName)" }
        ]
      }
      """
    Given path 'applications'
    And param check = true
    And header Authorization = 'Bearer ' + masterToken
    And request applicationV1
    When method post
    Then status 201
    And match response.id == applicationV1Id

    * def applicationDiscoveries =
      """
      {
        "discovery": [
          {
            "id": "#(movedModuleId)",
            "name": "#(movedModuleName)",
            "version": "#(movedModuleVersion)",
            "location": "#(movedModuleLocation)"
          },
          {
            "id": "#(retainedModuleId)",
            "name": "#(retainedModuleName)",
            "version": "#(retainedModuleVersion)",
            "location": "#(retainedModuleLocation)"
          }
        ]
      }
      """
    Given path 'modules', 'discovery'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request applicationDiscoveries
    When method post
    Then status 201
    And match response.discovery contains only applicationDiscoveries.discovery

    # Step 2: Create a tenant and entitle it to app-platform-minimal.
    * call read('classpath:common/eureka/tenant.feature@create') { tenantId: '#(tenantId)', tenantName: '#(tenantName)' }

    Given path 'applications'
    And param query = 'name=="' + appPlatformMinimal + '"'
    And param limit = 100
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.applicationDescriptors != '#[0]'
    * def appPlatformMinimalId = response.applicationDescriptors[0].id

    Given path 'entitlements'
    And param async = true
    And param purgeOnRollback = false
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { tenantId: '#(tenantId)', applications: ['#(appPlatformMinimalId)'] }
    When method post
    Then status 201
    * def appPlatformMinimalEntitlementFlowId = response.flowId

    * configure retry = { count: 40, interval: 15000 }
    Given path 'entitlement-flows', appPlatformMinimalEntitlementFlowId
    And param includeStages = true
    And header Authorization = 'Bearer ' + masterToken
    And retry until terminalFlowStatuses.includes(response.status)
    When method get
    Then status 200
    And match response.status == 'finished'

    # Step 3: Entitle the tenant to app-foo-1.0.0.

    Given path 'entitlements'
    And param async = true
    And param purgeOnRollback = false
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { tenantId: '#(tenantId)', applications: ['#(applicationV1Id)'] }
    When method post
    Then status 201
    * def entitlementFlowId = response.flowId

    * configure retry = { count: 40, interval: 15000 }
    Given path 'entitlement-flows', entitlementFlowId
    And param includeStages = true
    And header Authorization = 'Bearer ' + masterToken
    And retry until terminalFlowStatuses.includes(response.status)
    When method get
    Then status 200
    And match response.status == 'finished'

    # Step 4: Register app-foo-2.0.0 without mod-moved, which is being moved to the split application.
    * def applicationV2 =
      """
      {
        "name": "#(applicationName)",
        "version": "#(applicationV2Version)",
        "modules": [
          { "id": "#(retainedModuleId)", "name": "#(retainedModuleName)", "version": "#(retainedModuleVersion)" }
        ],
        "moduleDescriptors": [
          { "id": "#(retainedModuleId)", "name": "#(retainedModuleName)" }
        ]
      }
      """
    Given path 'applications'
    And param check = true
    And header Authorization = 'Bearer ' + masterToken
    And request applicationV2
    When method post
    Then status 201
    And match response.id == applicationV2Id

    # Step 5: Register app-foo-split-1.0.0 with the newer mod-moved-1.3.0 and mod-split-only-1.0.0.
    * def splitApplication =
      """
      {
        "name": "#(splitApplicationName)",
        "version": "#(splitApplicationVersion)",
        "modules": [
          { "id": "#(newerMovedModuleId)", "name": "#(movedModuleName)", "version": "#(newerMovedModuleVersion)" },
          { "id": "#(splitOnlyModuleId)", "name": "#(splitOnlyModuleName)", "version": "#(splitOnlyModuleVersion)" }
        ],
        "moduleDescriptors": [
          { "id": "#(newerMovedModuleId)", "name": "#(movedModuleName)" },
          { "id": "#(splitOnlyModuleId)", "name": "#(splitOnlyModuleName)" }
        ]
      }
      """
    Given path 'applications'
    And param check = true
    And header Authorization = 'Bearer ' + masterToken
    And request splitApplication
    When method post
    Then status 201
    And match response.id == splitApplicationId

    # Register a separate discovery for the newer mod-moved version.
    * def splitApplicationDiscoveries =
      """
      {
        "discovery": [
          {
            "id": "#(newerMovedModuleId)",
            "name": "#(movedModuleName)",
            "version": "#(newerMovedModuleVersion)",
            "location": "#(newerMovedModuleLocation)"
          },
          {
            "id": "#(splitOnlyModuleId)",
            "name": "#(splitOnlyModuleName)",
            "version": "#(splitOnlyModuleVersion)",
            "location": "#(splitOnlyModuleLocation)"
          }
        ]
      }
      """
    Given path 'modules', 'discovery'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request splitApplicationDiscoveries
    When method post
    Then status 201
    And match response.discovery contains only splitApplicationDiscoveries.discovery

    # Step 6: Replace app-foo-1.0.0 with both target applications while retaining app-platform-minimal.
    Given path 'entitlements', 'state'
    And param async = true
    And param purgeOnRollback = false
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { tenantId: '#(tenantId)', applications: ['#(appPlatformMinimalId)', '#(applicationV2Id)', '#(splitApplicationId)'] }
    When method put
    Then status 200
    * def stateFlowId = response.flowId

    Given path 'entitlement-flows', stateFlowId
    And param includeStages = true
    And header Authorization = 'Bearer ' + masterToken
    And retry until terminalFlowStatuses.includes(response.status)
    When method get
    Then status 200
    And match response.status == 'finished'

    # Step 7: Verify both fake application entitlements and their module sets.
    Given path 'entitlements'
    And param query = 'tenantId==' + tenantId
    And param includeModules = true
    And param limit = 10
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.totalRecords == 3

    * def entitlementByApplicationId = {}
    * eval karate.forEach(response.entitlements, entitlement => entitlementByApplicationId[entitlement.applicationId] = entitlement)
    * def applicationEntitlement = entitlementByApplicationId[applicationV2Id]
    * def splitApplicationEntitlement = entitlementByApplicationId[splitApplicationId]
    * def expectedApplicationModuleIds = ['#(retainedModuleId)']
    * def expectedSplitApplicationModuleIds = ['#(newerMovedModuleId)', '#(splitOnlyModuleId)']
    And match applicationEntitlement.modules contains only expectedApplicationModuleIds
    And match splitApplicationEntitlement.modules contains only expectedSplitApplicationModuleIds

    # Step 8: Cleanup - Revoke both fake applications while mod-roles-keycloak can still confirm events.
    Given path 'entitlements'
    And param purge = true
    And param async = true
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { tenantId: '#(tenantId)', applications: ['#(applicationV2Id)', '#(splitApplicationId)'] }
    When method delete
    Then status 200
    * def revokeFlowId = response.flowId

    Given path 'entitlement-flows', revokeFlowId
    And param includeStages = true
    And header Authorization = 'Bearer ' + masterToken
    And retry until terminalFlowStatuses.includes(response.status)
    When method get
    Then status 200
    And match response.status == 'finished'

    # Revoke app-platform-minimal only after both fake applications have been fully revoked.
    Given path 'entitlements'
    And param purge = true
    And param async = true
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { tenantId: '#(tenantId)', applications: ['#(appPlatformMinimalId)'] }
    When method delete
    Then status 200
    * def appPlatformMinimalRevokeFlowId = response.flowId

    Given path 'entitlement-flows', appPlatformMinimalRevokeFlowId
    And param includeStages = true
    And header Authorization = 'Bearer ' + masterToken
    And retry until terminalFlowStatuses.includes(response.status)
    When method get
    Then status 200
    And match response.status == 'finished'

    * call read('classpath:common/eureka/tenant.feature@delete') { tenantId: '#(tenantId)' }

    Given path 'applications', splitApplicationId
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    When method delete
    Then status 204

    Given path 'applications', applicationV2Id
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    When method delete
    Then status 204

    Given path 'applications', applicationV1Id
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    When method delete
    Then status 204
