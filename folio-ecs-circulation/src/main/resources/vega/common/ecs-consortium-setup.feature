@ignore
Feature: Common ECS consortium setup (tenants, consortium, inventory, circulation policies)

  # Sets up a two-tenant consortium (central + university) with inventory data,
  # circulation policies, and ECS TLR enabled.

  Background:
    * url baseUrl
    * configure readTimeout = 600000

  Scenario: setup consortium with central and university tenants
    * def eurekaLogin = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def setupTenant = read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant')
    * def putCaps = read('classpath:common-consortia/eureka/initData.feature@PutCaps')
    * def setupCirculationPolicies = read('classpath:vega/ecs-requests/ecs-circulation-policies.feature')

    # Fixed UUIDs for inventory entities
    * callonce read('classpath:vega/ecs-requests/ecs-requests-variables.feature')

    * def centralTenantUuid = centralTenantId.length == 36 ? centralTenantId : karate.get('centralTenantUuid')
    * eval karate.set('centralTenantUuid', centralTenantUuid)
    * eval karate.set('centralTenantId', centralTenant)

    # Merge base permissions with any additional permissions passed by the caller
    * table baseModules
      | name                        |
      | 'mod-permissions'           |
      | 'okapi'                     |
      | 'mod-users'                 |
      | 'mod-login'                 |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-consortia'             |
      | 'mod-circulation-storage'   |
      | 'mod-circulation'           |
      | 'mod-circulation-bff'       |
      | 'mod-tlr'                   |
      | 'mod-search'                |

    * table baseUserPermissions
      | name                                                        |
      | 'users.item.post'                                           |
      | 'users.item.get'                                            |
      | 'users.collection.get'                                      |
      | 'usergroups.item.post'                                      |
      | 'inventory-storage.service-points.item.post'                |
      | 'inventory-storage.holdings.item.post'                      |
      | 'inventory-storage.items.item.post'                         |
      | 'inventory-storage.instance-types.item.post'                |
      | 'inventory-storage.loan-types.item.post'                    |
      | 'inventory-storage.material-types.item.post'                |
      | 'inventory-storage.location-units.institutions.item.post'   |
      | 'inventory-storage.location-units.campuses.item.post'       |
      | 'inventory-storage.location-units.libraries.item.post'      |
      | 'inventory-storage.locations.item.post'                     |
      | 'inventory-storage.holdings-sources.item.post'              |
      | 'inventory.instances.item.get'                              |
      | 'inventory.instances.item.post'                             |
      | 'inventory.items.item.post'                                 |
      | 'circulation-storage.circulation-rules.put'                 |
      | 'circulation-storage.loan-policies.item.post'               |
      | 'circulation-storage.patron-notice-policies.item.post'      |
      | 'circulation-storage.request-policies.item.post'            |
      | 'lost-item-fees-policies.item.post'                         |
      | 'overdue-fines-policies.item.post'                          |
      | 'circulation.settings.item.post'                            |
      | 'tlr.settings.put'                                          |
      | 'consortia.sharing-instances.item.post'                     |
      | 'consortia.sharing-instances.collection.get'                |
      | 'user-tenants.collection.get'                               |
      | 'consortia.user-tenants.collection.get'                     |
      | 'consortia.user-tenants.item.post'                          |
      | 'circulation-bff.requests.allowed-service-points.get'       |
      | 'circulation-bff.requests.post'                             |
      | 'circulation.requests.item.post'                            |
      | 'search.index.instance-records.reindex.full.post'           |
      | 'circulation-bff.pick-slips.collection.get'                 |
      | 'circulation-bff.search-slips.collection.get'               |

    * def modules = baseModules
    * def userPermissions = baseUserPermissions

    # ========== Step 1: Create and initialize tenants ==========
    # Pre-emptive cleanup: delete any leftover tenants/realms from a previous failed run.
    * configure abortedStepsShouldPass = true
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') { tenantName: '#(universityTenant)', tenantId: '#(universityTenantId)' }
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') { tenantName: '#(centralTenant)', tenantId: '#(centralTenantUuid)' }
    * configure abortedStepsShouldPass = false

    * call setupTenant { tenant: '#(centralTenant)', tenantId: '#(centralTenantUuid)', user: '#(consortiaAdmin)' }
    * call setupTenant { tenant: '#(universityTenant)', tenantId: '#(universityTenantId)', user: '#(universityUser1)' }

    # ========== Step 2: Create consortium and register tenants ==========
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    # --- Create consortium (idempotent: 409 means already exists from a previous run) ---
    * def ecsConsortiumHeaders = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    * configure headers = ecsConsortiumHeaders
    * configure retry = { count: 10, interval: 10000 }
    Given path 'consortia'
    And request { id: '#(consortiumId)', name: '#(centralTenant + "name for test")' }
    And retry until responseStatus == 201 || responseStatus == 409
    When method POST
    * print 'ECS setup: setupConsortium responseStatus:', responseStatus
    * if (responseStatus != 201 && responseStatus != 409) karate.fail('ECS setup: unexpected consortium create status ' + responseStatus + ' body: ' + karate.toJson(response))

    # --- Register central tenant in consortium (idempotent, then wait for COMPLETED) ---
    * configure retry = { count: 30, interval: 15000 }
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '#(centralTenant)', code: 'CON', name: '#(centralTenant + " tenants name")', isCentral: true }
    And retry until responseStatus == 201 || responseStatus == 409 || responseStatus == 422
    When method POST
    * print 'ECS setup: register centralTenant responseStatus:', responseStatus, 'body:', response
    * if (responseStatus != 201 && responseStatus != 409 && responseStatus != 422) karate.fail('ECS setup: unexpected central tenant register status ' + responseStatus + ' body: ' + karate.toJson(response))

    * configure retry = { count: 20, interval: 15000 }
    Given path 'consortia', consortiumId, 'tenants', centralTenant
    And retry until responseStatus == 200 && (response.setupStatus == 'COMPLETED' || response.setupStatus == 'FAILED')
    When method GET
    Then status 200
    * print 'ECS setup: centralTenant setupStatus:', response.setupStatus
    * if (response.setupStatus != 'COMPLETED') karate.fail('ECS setup: centralTenant setupStatus is ' + response.setupStatus)

    # --- Register university tenant in consortium (idempotent, then wait for COMPLETED) ---
    * configure retry = { count: 30, interval: 15000 }
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And request { id: '#(universityTenant)', code: 'UNI', name: '#(universityTenant + " tenants name")', isCentral: false }
    And retry until responseStatus == 201 || responseStatus == 409 || responseStatus == 422
    When method POST
    * print 'ECS setup: register universityTenant responseStatus:', responseStatus, 'body:', response
    * if (responseStatus != 201 && responseStatus != 409 && responseStatus != 422) karate.fail('ECS setup: unexpected university tenant register status ' + responseStatus + ' body: ' + karate.toJson(response))

    * configure retry = { count: 20, interval: 15000 }
    Given path 'consortia', consortiumId, 'tenants', universityTenant
    And retry until responseStatus == 200 && (response.setupStatus == 'COMPLETED' || response.setupStatus == 'FAILED')
    When method GET
    Then status 200
    * print 'ECS setup: universityTenant setupStatus:', response.setupStatus
    * if (response.setupStatus != 'COMPLETED') karate.fail('ECS setup: universityTenant setupStatus is ' + response.setupStatus)

    # Grant shadow consortia_admin in university tenant the permissions needed for cross-tenant operations
    * table baseShadowPermissions
      | name                                                  |
      | 'circulation.requests.item.post'                      |
      | 'circulation.requests.item.get'                       |
      | 'circulation-bff.requests.allowed-service-points.get' |
      | 'circulation-bff.requests.post'                       |
      | 'inventory.instances.item.get'                        |
      | 'inventory.items.item.get'                            |
      | 'inventory-storage.holdings.item.get'                 |
      | 'user-tenants.collection.get'                         |
      | 'circulation-bff.pick-slips.collection.get'           |
      | 'circulation-bff.search-slips.collection.get'         |

    * def userPermissions = baseShadowPermissions

    * def shadowConsortiaAdmin = { id: '#(consortiaAdmin.id)', tenant: '#(universityTenant)' }
    * configure cookies = null
    * call putCaps { tenant: '#(universityTenant)', user: '#(shadowConsortiaAdmin)' }

    # Re-login as consortia_admin to restore the central tenant okapitoken
    # (putCaps calls getAuthorizationToken for universityTenant, overwriting okapitoken)
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    # Wait for consortium registration to propagate through Kafka
    * configure retry = { count: 20, interval: 30000 }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }
    Given path 'user-tenants'
    And param tenantId = centralTenant
    And retry until responseStatus == 200
    When method GET
    Then status 200

    # ========== Step 3: Initialize mod-search indices ==========
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    Given path 'search/index/instance-records/reindex/full'
    And request {}
    When method POST
    Then status 200

    # ========== Step 4: Setup inventory data in central tenant ==========
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }

    Given path 'location-units/institutions'
    And request { id: '#(ecsInstitutionId)', name: 'ECS Test Institution Central', code: 'ECSI-C' }
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request { id: '#(ecsCampusId)', name: 'ECS Test Campus Central', code: 'ECSC-C', institutionId: '#(ecsInstitutionId)' }
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request { id: '#(ecsLibraryId)', name: 'ECS Test Library Central', code: 'ECSL-C', campusId: '#(ecsCampusId)' }
    When method POST
    Then status 201

    Given path 'service-points'
    And request { id: '#(ecsServicePointId)', name: 'ECS Central Service Point', code: 'ECS-SP-C', discoveryDisplayName: 'ECS Central Service Point', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then status 201

    Given path 'instance-types'
    And request { id: '#(ecsInstanceTypeId)', name: 'ECS Instance Type', code: 'ECSI-T', source: 'local' }
    When method POST
    Then status 201

    Given path 'loan-types'
    And request { id: '#(ecsLoanTypeId)', name: 'ECS Loan Type' }
    When method POST
    Then status 201

    Given path 'material-types'
    And request { id: '#(ecsMaterialTypeId)', name: 'ECS Material Type' }
    When method POST
    Then status 201

    Given path 'holdings-sources'
    And request { id: '#(ecsHoldingsSourceId)', name: 'ECS FOLIO Central' }
    When method POST
    Then status 201

    Given path 'locations'
    And request
      """
      {
        "id": "#(ecsLocationId)",
        "name": "ECS Central Location",
        "code": "ECS-LOC-C",
        "institutionId": "#(ecsInstitutionId)",
        "campusId": "#(ecsCampusId)",
        "libraryId": "#(ecsLibraryId)",
        "primaryServicePoint": "#(ecsServicePointId)",
        "servicePointIds": ["#(ecsServicePointId)"]
      }
      """
    When method POST
    Then status 201

    # ========== Step 5: Setup inventory data in university tenant ==========
    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(universityLogin.okapitoken)', 'x-okapi-tenant': '#(universityTenant)' }

    Given path 'location-units/institutions'
    And request { id: '#(uniInstitutionId)', name: 'ECS Test Institution University', code: 'ECSI-U' }
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request { id: '#(uniCampusId)', name: 'ECS Test Campus University', code: 'ECSC-U', institutionId: '#(uniInstitutionId)' }
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request { id: '#(uniLibraryId)', name: 'ECS Test Library University', code: 'ECSL-U', campusId: '#(uniCampusId)' }
    When method POST
    Then status 201

    Given path 'service-points'
    And request { id: '#(uniServicePointId)', name: 'ECS University Service Point', code: 'ECS-SP-U', discoveryDisplayName: 'ECS University Service Point', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then status 201

    # Also create the central service point in the university tenant so it is available
    # as a pickup location without relying on cross-tenant Kafka replication.
    Given path 'service-points'
    And request { id: '#(ecsServicePointId)', name: 'ECS Central Service Point', code: 'ECS-SP-C', discoveryDisplayName: 'ECS Central Service Point', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then status 201

    Given path 'instance-types'
    And request { id: '#(uniInstanceTypeId)', name: 'ECS Instance Type', code: 'ECSI-T', source: 'local' }
    When method POST
    Then status 201

    Given path 'loan-types'
    And request { id: '#(uniLoanTypeId)', name: 'ECS Loan Type' }
    When method POST
    Then status 201

    Given path 'material-types'
    And request { id: '#(uniMaterialTypeId)', name: 'ECS Material Type' }
    When method POST
    Then status 201

    Given path 'holdings-sources'
    And request { id: '#(uniHoldingsSourceId)', name: 'ECS FOLIO University' }
    When method POST
    Then status 201

    Given path 'locations'
    And request
      """
      {
        "id": "#(uniLocationId)",
        "name": "ECS University Location",
        "code": "ECS-LOC-U",
        "institutionId": "#(uniInstitutionId)",
        "campusId": "#(uniCampusId)",
        "libraryId": "#(uniLibraryId)",
        "primaryServicePoint": "#(ecsServicePointId)",
        "servicePointIds": ["#(ecsServicePointId)", "#(uniServicePointId)"]
      }
      """
    When method POST
    Then status 201

    # ========== Step 6: Setup circulation policies and enable ECS TLR ==========
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    # Enable ECS TLR feature at consortium level
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true' }
    Given path 'tlr/settings'
    And request { "ecsTlrFeatureEnabled": true, "excludeFromEcsRequestLendingTenantSearch": [] }
    When method PUT
    Then status 204

    * call setupCirculationPolicies { tenant: '#(centralTenant)', okapitoken: '#(okapitoken)', policyLabel: 'Central' }

    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * call setupCirculationPolicies { tenant: '#(universityTenant)', okapitoken: '#(universityLogin.okapitoken)', policyLabel: 'University' }
