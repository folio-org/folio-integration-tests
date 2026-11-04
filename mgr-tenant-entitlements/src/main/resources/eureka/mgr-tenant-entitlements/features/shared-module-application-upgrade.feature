Feature: upgrade between application versions that share a module version

  # This test verifies that two versions of the same application can include the same mod-unchanged version.
  # A tenant is first entitled to app-foo-1.0.0 and then upgraded to app-foo-2.0.0. After the upgrade, mod-unchanged remains
  # at version 1.2.3 while mod-upgraded changes from version 1.1.0 to 1.2.0. The test also verifies discovery registration
  # and reuse. The discovery URLs are fake, so this test does not verify live API routing.
  #
  # Initial entitlement state: app-foo-1.0.0
  # - mod-unchanged-1.2.3
  # - mod-upgraded-1.1.0
  #
  # Target entitlement state: app-foo-2.0.0
  # - mod-unchanged-1.2.3
  # - mod-upgraded-1.2.0

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * def keycloakResponse = callonce read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def masterToken = keycloakResponse.response.access_token
    * def uniqueSuffix = nowMillis()

    * def applicationName = 'it-app-foo-' + uniqueSuffix
    * def applicationV1Version = '1.0.0'
    * def applicationV2Version = '2.0.0'
    * def applicationV1Id = applicationName + '-' + applicationV1Version
    * def applicationV2Id = applicationName + '-' + applicationV2Version

    * def unchangedModuleName = 'it-mod-unchanged-' + uniqueSuffix
    * def unchangedModuleVersion = '1.2.3'
    * def unchangedModuleId = unchangedModuleName + '-' + unchangedModuleVersion
    * def unchangedModuleLocation = 'http://' + unchangedModuleName + ':8080'

    * def upgradedModuleName = 'it-mod-upgraded-' + uniqueSuffix
    * def upgradedModuleV1Version = '1.1.0'
    * def upgradedModuleV2Version = '1.2.0'
    * def upgradedModuleV1Id = upgradedModuleName + '-' + upgradedModuleV1Version
    * def upgradedModuleV2Id = upgradedModuleName + '-' + upgradedModuleV2Version
    * def upgradedModuleV1Location = 'http://' + upgradedModuleName + '-v1:8080'
    * def upgradedModuleV2Location = 'http://' + upgradedModuleName + '-v2:8080'

    * def tenantId = uuid()
    * def tenantName = 'sharedapp' + uniqueSuffix

    * def terminalFlowStatuses = ['finished', 'cancelled', 'cancellation_failed', 'failed']

  @Positive
  Scenario: upgrade a tenant when both application versions contain the same module version
    # Step 1: Register app-foo-1.0.0 and discoveries for mod-unchanged-1.2.3 and mod-upgraded-1.1.0.
    * def applicationV1 =
      """
      {
        "name": "#(applicationName)",
        "version": "#(applicationV1Version)",
        "modules": [
          { "id": "#(unchangedModuleId)", "name": "#(unchangedModuleName)", "version": "#(unchangedModuleVersion)" },
          { "id": "#(upgradedModuleV1Id)", "name": "#(upgradedModuleName)", "version": "#(upgradedModuleV1Version)" }
        ],
        "moduleDescriptors": [
          { "id": "#(unchangedModuleId)", "name": "#(unchangedModuleName)" },
          { "id": "#(upgradedModuleV1Id)", "name": "#(upgradedModuleName)" }
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

    * def applicationV1Discoveries =
      """
      {
        "discovery": [
          {
            "id": "#(unchangedModuleId)",
            "name": "#(unchangedModuleName)",
            "version": "#(unchangedModuleVersion)",
            "location": "#(unchangedModuleLocation)"
          },
          {
            "id": "#(upgradedModuleV1Id)",
            "name": "#(upgradedModuleName)",
            "version": "#(upgradedModuleV1Version)",
            "location": "#(upgradedModuleV1Location)"
          }
        ]
      }
      """
    Given path 'modules', 'discovery'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request applicationV1Discoveries
    When method post
    Then status 201
    And match response.discovery contains only applicationV1Discoveries.discovery

    # Step 2: Create a tenant and entitle it to app-foo-1.0.0.
    * call read('classpath:common/eureka/tenant.feature@create') { tenantId: '#(tenantId)', tenantName: '#(tenantName)' }

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

    # Step 3: Register app-foo-2.0.0 and upsert discoveries for the shared mod-unchanged and newer mod-upgraded.
    * def applicationV2 =
      """
      {
        "name": "#(applicationName)",
        "version": "#(applicationV2Version)",
        "modules": [
          { "id": "#(unchangedModuleId)", "name": "#(unchangedModuleName)", "version": "#(unchangedModuleVersion)" },
          { "id": "#(upgradedModuleV2Id)", "name": "#(upgradedModuleName)", "version": "#(upgradedModuleV2Version)" }
        ],
        "moduleDescriptors": [
          { "id": "#(unchangedModuleId)", "name": "#(unchangedModuleName)" },
          { "id": "#(upgradedModuleV2Id)", "name": "#(upgradedModuleName)" }
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

    # The shared module is deliberately included again to verify that its existing discovery can be reused.
    * def applicationV2Discoveries =
      """
      {
        "discovery": [
          {
            "id": "#(unchangedModuleId)",
            "name": "#(unchangedModuleName)",
            "version": "#(unchangedModuleVersion)",
            "location": "#(unchangedModuleLocation)"
          },
          {
            "id": "#(upgradedModuleV2Id)",
            "name": "#(upgradedModuleName)",
            "version": "#(upgradedModuleV2Version)",
            "location": "#(upgradedModuleV2Location)"
          }
        ]
      }
      """
    Given path 'modules', 'discovery'
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request applicationV2Discoveries
    When method post
    Then status 201
    And match response.discovery contains only applicationV2Discoveries.discovery

    Given path 'applications', applicationV2Id, 'discovery'
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    * def applicationV2DiscoveryIds = karate.map(response.discovery, discovery => discovery.id)
    * def expectedApplicationV2DiscoveryIds = ['#(unchangedModuleId)', '#(upgradedModuleV2Id)']
    And match applicationV2DiscoveryIds contains only expectedApplicationV2DiscoveryIds

    # Step 4: Upgrade the tenant from app-foo-1.0.0 to app-foo-2.0.0 using the desired-state API.
    Given path 'entitlements', 'state'
    And param async = true
    And param purgeOnRollback = false
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { tenantId: '#(tenantId)', applications: ['#(applicationV2Id)'] }
    When method put
    Then status 200
    * def upgradeFlowId = response.flowId

    Given path 'entitlement-flows', upgradeFlowId
    And param includeStages = true
    And header Authorization = 'Bearer ' + masterToken
    And retry until terminalFlowStatuses.includes(response.status)
    When method get
    Then status 200
    And match response.status == 'finished'

    # Step 5: Verify that the tenant is entitled only to app-foo-2.0.0 and its expected modules.
    Given path 'entitlements'
    And param query = 'tenantId==' + tenantId
    And param includeModules = true
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.totalRecords == 1
    And match response.entitlements[0].applicationId == applicationV2Id
    * def expectedModuleIds = ['#(unchangedModuleId)', '#(upgradedModuleV2Id)']
    And match response.entitlements[0].modules contains only expectedModuleIds

    # Step 6: Cleanup - Revoke the application, delete the tenant, and remove both test application versions.
    Given path 'entitlements'
    And param purge = true
    And param async = true
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    And request { tenantId: '#(tenantId)', applications: ['#(applicationV2Id)'] }
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

    * call read('classpath:common/eureka/tenant.feature@delete') { tenantId: '#(tenantId)' }

    Given path 'applications', applicationV2Id
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    When method delete
    Then status 204

    # The shared discovery must remain because app-foo-1.0.0 still references it.
    Given path 'modules', unchangedModuleId, 'discovery'
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 200
    And match response.location == unchangedModuleLocation

    Given path 'modules', upgradedModuleV2Id, 'discovery'
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 404

    Given path 'applications', applicationV1Id
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    When method delete
    Then status 204

    # Removing the final application reference also removes its module discoveries.
    Given path 'modules', unchangedModuleId, 'discovery'
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 404

    Given path 'modules', upgradedModuleV1Id, 'discovery'
    And header Authorization = 'Bearer ' + masterToken
    When method get
    Then status 404
