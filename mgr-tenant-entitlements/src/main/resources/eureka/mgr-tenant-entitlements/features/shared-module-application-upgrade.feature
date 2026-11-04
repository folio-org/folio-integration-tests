Feature: upgrade between application versions that share a module version

  # This test verifies that two versions of the same application can be registered when they share an unchanged module.
  # It then upgrades a tenant from the first application version to the second and confirms that the shared module remains
  # entitled while the changed module is upgraded to its newer version.

  Background:
    * url baseUrl
    * configure readTimeout = 3000000
    * def keycloakResponse = callonce read('classpath:common/eureka/keycloak.feature@getKeycloakMasterToken')
    * def masterToken = keycloakResponse.response.access_token
    * def uniqueSuffix = nowMillis()

    * def applicationName = 'it-app-foo-' + uniqueSuffix
    * def applicationV1Id = applicationName + '-1.0.0'
    * def applicationV2Id = applicationName + '-2.0.0'

    * def sharedModuleName = 'it-mod-foo-' + uniqueSuffix
    * def sharedModuleId = sharedModuleName + '-1.2.3'

    * def changedModuleName = 'it-mod-bar-' + uniqueSuffix
    * def changedModuleV1Id = changedModuleName + '-1.1.0'
    * def changedModuleV2Id = changedModuleName + '-1.2.0'

    * def tenantId = uuid()
    * def tenantName = 'sharedapp' + uniqueSuffix

    * def terminalFlowStatuses = ['finished', 'cancelled', 'cancellation_failed', 'failed']

  @Positive
  Scenario: upgrade a tenant when both application versions contain the same module version
    # Step 1: Register app-foo-1.0.0 with mod-foo-1.2.3 and mod-bar-1.1.0.
    * def applicationV1 =
      """
      {
        "name": "#(applicationName)",
        "version": "1.0.0",
        "modules": [
          { "id": "#(sharedModuleId)", "name": "#(sharedModuleName)", "version": "1.2.3" },
          { "id": "#(changedModuleV1Id)", "name": "#(changedModuleName)", "version": "1.1.0" }
        ],
        "moduleDescriptors": [
          { "id": "#(sharedModuleId)", "name": "#(sharedModuleName)" },
          { "id": "#(changedModuleV1Id)", "name": "#(changedModuleName)" }
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

    # Step 3: Register app-foo-2.0.0 with the same mod-foo-1.2.3 and the newer mod-bar-1.2.0.
    * def applicationV2 =
      """
      {
        "name": "#(applicationName)",
        "version": "2.0.0",
        "modules": [
          { "id": "#(sharedModuleId)", "name": "#(sharedModuleName)", "version": "1.2.3" },
          { "id": "#(changedModuleV2Id)", "name": "#(changedModuleName)", "version": "1.2.0" }
        ],
        "moduleDescriptors": [
          { "id": "#(sharedModuleId)", "name": "#(sharedModuleName)" },
          { "id": "#(changedModuleV2Id)", "name": "#(changedModuleName)" }
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
    * def expectedModuleIds = ['#(sharedModuleId)', '#(changedModuleV2Id)']
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

    Given path 'applications', applicationV1Id
    And header Authorization = 'Bearer ' + masterToken
    And header X-Okapi-Token = masterToken
    When method delete
    Then status 204
