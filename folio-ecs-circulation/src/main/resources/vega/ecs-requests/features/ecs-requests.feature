# FAT-21604, Create Karate tests for ILR and TLR ECS requests via mod-circulation-bff
@parallel=false
Feature: ECS ILR and TLR requests creation via mod-circulation-bff

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * callonce login admin

    * table modules
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

    * table userPermissions
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

    * def eurekaLogin = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def setupTenant = read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant')
    * def setupConsortium = read('classpath:common-consortia/eureka/consortium.feature@SetupConsortia')
    * def setupTenantForConsortia = read('classpath:common-consortia/eureka/consortium.feature@SetupTenantForConsortia')
    * def putCaps = read('classpath:common-consortia/eureka/initData.feature@PutCaps')
    * def setupCirculationPolicies = read('classpath:vega/ecs-requests/ecs-circulation-policies.feature')
    * def setupInventory = read('classpath:vega/ecs-requests/ecs-inventory-setup.feature')

    # Fixed UUIDs for inventory entities shared across scenarios
    * callonce read('classpath:vega/ecs-requests/ecs-requests-variables.feature')

    * def centralTenantUuid = centralTenantId.length == 36 ? centralTenantId : karate.get('centralTenantUuid')
    * eval karate.set('centralTenantUuid', centralTenantUuid)
    * eval karate.set('centralTenantId', centralTenant)

  Scenario: create and initialize central and university tenants
    # Pre-emptive cleanup: delete any leftover tenants/realms from a previous failed run.
    # Uses abortedStepsShouldPass so this is a no-op when the tenants don't exist yet.
    * configure abortedStepsShouldPass = true
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') { tenantName: '#(universityTenant)', tenantId: '#(universityTenantId)' }
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') { tenantName: '#(centralTenant)', tenantId: '#(centralTenantUuid)' }
    * configure abortedStepsShouldPass = false

    * call setupTenant { tenant: '#(centralTenant)', tenantId: '#(centralTenantUuid)', user: '#(consortiaAdmin)' }
    * call setupTenant { tenant: '#(universityTenant)', tenantId: '#(universityTenantId)', user: '#(universityUser1)' }

  Scenario: create consortium and register central and university tenants
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    * call setupConsortium { tenant: '#(centralTenant)' }
    * call setupTenantForConsortia { tenant: '#(centralTenant)', id: '#(centralTenantId)', isCentral: true, code: 'CON' }
    * call setupTenantForConsortia { tenant: '#(universityTenant)', id: '#(universityTenantId)', isCentral: false, code: 'UNI' }

    # Grant shadow consortia_admin in university tenant the permissions needed for cross-tenant requests
    * table userPermissions
      | name                                                  |
      | 'circulation.requests.item.post'                      |
      | 'circulation.requests.item.get'                       |
      | 'circulation-bff.requests.allowed-service-points.get' |
      | 'circulation-bff.requests.post'                       |
      | 'inventory.instances.item.get'                        |
      | 'inventory.items.item.get'                            |
      | 'inventory-storage.holdings.item.get'                 |
      | 'user-tenants.collection.get'                         |
      | 'consortia.user-tenants.collection.get'               |
      | 'consortia.user-tenants.item.post'                    |
      | 'consortia.sharing-instances.item.post'               |
      | 'consortia.sharing-instances.collection.get'          |

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

  Scenario: initialize mod-search indices for central tenant
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    Given path 'search/index/instance-records/reindex/full'
    And request {}
    When method POST
    Then status 200

  Scenario: setup inventory data in central tenant
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(centralLogin.okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }

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

  Scenario: setup inventory data in university tenant
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

  Scenario: setup circulation policies and enable ECS TLR
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

  Scenario: create ILR ECS request via mod-circulation-bff
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken
    * def headersCentral = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }

    # Create user group and patron user in central tenant
    * configure headers = headersCentral
    * def groupId = uuid()
    Given path 'groups'
    And request { id: '#(groupId)', group: '#("ecs-ilr-grp-" + randomMillis())', desc: 'ECS ILR test group', expirationOffsetInDays: '60' }
    When method POST
    Then status 201

    * def userId = uuid()
    * def userBarcode = 'ECS-ILR-' + randomMillis()
    Given path 'users'
    And request
      """
      {
        "id": "#(userId)",
        "username": "#(userBarcode)",
        "barcode": "#(userBarcode)",
        "active": true,
        "type": "patron",
        "patronGroup": "#(groupId)",
        "personal": { "lastName": "ECSTest", "firstName": "ILRUser", "email": "ecs-ilr@test.com", "preferredContactTypeId": "002", "addresses": [] },
        "departments": [],
        "expirationDate": "2028-12-31T23:59:59.000+00:00"
      }
      """
    When method POST
    Then status 201

    Given path 'users', userId
    When method GET
    Then status 200
    * def requester = response

    # Create inventory in university tenant and share instance to central
    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * def inventoryParams = { okapitoken: '#(okapitoken)', centralTenant: '#(centralTenant)', consortiumId: '#(consortiumId)', uniOkapitoken: '#(universityLogin.okapitoken)', universityTenant: '#(universityTenant)', instanceTypeId: '#(uniInstanceTypeId)', locationId: '#(uniLocationId)', holdingsSourceId: '#(uniHoldingsSourceId)', materialTypeId: '#(uniMaterialTypeId)', loanTypeId: '#(uniLoanTypeId)', instanceTitle: 'ECS ILR Test Instance' }
    * def inventory = call setupInventory inventoryParams

    # configure headers with a token-refreshing function so every retry attempt gets a fresh token
    * configure headers = makeHeadersFn(consortiaAdmin, centralTenant)
    * configure retry = { count: 20, interval: 15000 }
    Given path 'circulation-bff/requests/allowed-service-points'
    And param requesterId = userId
    And param operation = 'create'
    And param itemId = inventory.itemId
    And retry until responseStatus == 200 && response.Page && response.Page.filter(function(sp){ return sp.id == ecsServicePointId }).length > 0
    When method GET
    Then status 200

    # Restore static headers with a fresh token for the request creation POST
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    # Create ILR ECS request via mod-circulation-bff
    Given path 'circulation-bff/requests'
    And headers { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }
    And request
      """
      {
        "id": "#(uuid())",
        "requestType": "Page",
        "requestLevel": "Item",
        "requestDate": "#(java.time.Instant.now().toString())",
        "fulfillmentPreference": "Hold Shelf",
        "instanceId": "#(inventory.instanceId)",
        "holdingsRecordId": "#(inventory.holdingId)",
        "itemId": "#(inventory.itemId)",
        "item": { "barcode": "#(inventory.itemBarcode)" },
        "requesterId": "#(userId)",
        "requester": "#(requester)",
        "pickupServicePointId": "#(ecsServicePointId)"
      }
      """
    When method POST
    Then status 201
    And match response.requestLevel == 'Item'
    And match response.itemId == inventory.itemId
    And match response.instanceId == inventory.instanceId
    And match response.requesterId == userId
    And match response.pickupServicePointId == ecsServicePointId
    And match response.status == 'Open - Not yet filled'

  Scenario: create TLR ECS request via mod-circulation-bff
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken
    * def headersCentral = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }

    # Create user group and patron user in central tenant
    * configure headers = headersCentral
    * def groupId = uuid()
    Given path 'groups'
    And request { id: '#(groupId)', group: '#("ecs-tlr-grp-" + randomMillis())', desc: 'ECS TLR test group', expirationOffsetInDays: '60' }
    When method POST
    Then status 201

    * def userId = uuid()
    * def userBarcode = 'ECS-TLR-' + randomMillis()
    Given path 'users'
    And request
      """
      {
        "id": "#(userId)",
        "username": "#(userBarcode)",
        "barcode": "#(userBarcode)",
        "active": true,
        "type": "patron",
        "patronGroup": "#(groupId)",
        "personal": { "lastName": "ECSTest", "firstName": "TLRUser", "email": "ecs-tlr@test.com", "preferredContactTypeId": "002", "addresses": [] },
        "departments": [],
        "expirationDate": "2028-12-31T23:59:59.000+00:00"
      }
      """
    When method POST
    Then status 201

    Given path 'users', userId
    When method GET
    Then status 200
    * def requester = response

    # Create inventory in university tenant and share instance to central
    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * def inventoryParams = { okapitoken: '#(okapitoken)', centralTenant: '#(centralTenant)', consortiumId: '#(consortiumId)', uniOkapitoken: '#(universityLogin.okapitoken)', universityTenant: '#(universityTenant)', instanceTypeId: '#(uniInstanceTypeId)', locationId: '#(uniLocationId)', holdingsSourceId: '#(uniHoldingsSourceId)', materialTypeId: '#(uniMaterialTypeId)', loanTypeId: '#(uniLoanTypeId)', instanceTitle: 'ECS TLR Test Instance' }
    * def inventory = call setupInventory inventoryParams

    # configure headers with a token-refreshing function so every retry attempt gets a fresh token
    * configure headers = makeHeadersFn(consortiaAdmin, centralTenant)
    * configure retry = { count: 20, interval: 15000 }
    Given path 'circulation-bff/requests/allowed-service-points'
    And param requesterId = userId
    And param operation = 'create'
    And param instanceId = inventory.instanceId
    And retry until responseStatus == 200 && response.Page && response.Page.filter(function(sp){ return sp.id == ecsServicePointId }).length > 0
    When method GET
    Then status 200

    # Restore static headers with a fresh token for the request creation POST
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    # Create TLR ECS request via mod-circulation-bff
    Given path 'circulation-bff/requests'
    And headers { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }
    And request
      """
      {
        "id": "#(uuid())",
        "requestType": "Page",
        "requestLevel": "Title",
        "requestDate": "#(java.time.Instant.now().toString())",
        "fulfillmentPreference": "Hold Shelf",
        "instanceId": "#(inventory.instanceId)",
        "requesterId": "#(userId)",
        "requester": "#(requester)",
        "pickupServicePointId": "#(ecsServicePointId)"
      }
      """
    When method POST
    Then status 201
    And match response.requestLevel == 'Title'
    And match response.instanceId == inventory.instanceId
    And match response.requesterId == userId
    And match response.pickupServicePointId == ecsServicePointId
    And match response.status == 'Open - Not yet filled'
