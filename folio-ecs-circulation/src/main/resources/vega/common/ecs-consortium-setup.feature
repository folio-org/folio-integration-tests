@ignore
Feature: Common ECS setup (inventory, circulation policies, ECS TLR, shadow-user capabilities)

  # Adds the ECS-request data on top of the shared consortium: inventory in central and
  # university, circulation policies, and the ECS TLR feature flag.
  #
  # The central/university/college tenants and the consortium itself are NOT created here - they
  # are created once per build by vega/common/consortium-bootstrap.feature, invoked from
  # FolioEcsCirculationTests#bootstrapConsortium (@Order(0)). Everything this feature does is
  # additive against already-initialised tenants.
  #
  # This feature is callonce'd by BOTH staff-slips.feature and ecs-requests.feature, and callonce
  # is scoped per feature file (each runFeature call is a separate Karate suite), so it executes
  # twice per build. That is why it must never create or delete a tenant: it used to run a
  # delete/recreate cycle on the shared tenants on each of those two executions, wiping out data
  # the other features - including the long-running mediated-request workflow - depended on.

  Background:
    * url baseUrl
    * configure readTimeout = 600000

  Scenario: setup ECS inventory, policies and shadow-user capabilities
    * def eurekaLogin = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def putCaps = read('classpath:common-consortia/eureka/initData.feature@PutCaps')
    * def setupCirculationPolicies = read('classpath:vega/ecs-requests/ecs-circulation-policies.feature')

    # Fixed UUIDs for inventory entities
    * callonce read('classpath:vega/ecs-requests/ecs-requests-variables.feature')

    # Modules and permissions required by the ECS suites. Kept for documentation only - tenant
    # entitlement happens in consortium-bootstrap.feature, whose lists are the union of every
    # suite's requirements and must be updated if these grow.
    * table baseModules
      | name                        |
      | 'mod-permissions'           |
      | 'okapi'                     |
      | 'mod-users'                 |
      | 'mod-login-keycloak'        |
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

    # ========== Step 1: Confirm the shared consortium is ready ==========
    # Tenants and consortium registration are done by consortium-bootstrap.feature. Fail fast and
    # clearly here if that did not happen, instead of erroring deep inside a test scenario.
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    * configure retry = { count: 10, interval: 10000 }
    Given path 'consortia', consortiumId, 'tenants'
    And retry until responseStatus == 200 && response.totalRecords == 3
    When method GET
    Then status 200
    And match response.tenants[*].id contains centralTenant
    And match response.tenants[*].id contains universityTenant

    # ========== Step 2: Grant shadow-user capabilities ==========
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
    Then match [200, 400] contains responseStatus

    # ========== Step 4: Setup inventory data in central tenant ==========
    # All entities below use the fixed UUIDs from ecs-requests-variables.feature, and this feature
    # runs twice per build (once for staff-slips, once for ecs-requests) against tenants that are
    # no longer recreated in between. Creation is therefore idempotent: 201 = created, 422 = already
    # created by the earlier invocation (or replicated from central via Kafka).
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }

    Given path 'location-units/institutions'
    And request { id: '#(ecsInstitutionId)', name: 'ECS Test Institution Central', code: 'ECSI-C' }
    When method POST
    Then match [201, 422] contains responseStatus

    Given path 'location-units/campuses'
    And request { id: '#(ecsCampusId)', name: 'ECS Test Campus Central', code: 'ECSC-C', institutionId: '#(ecsInstitutionId)' }
    When method POST
    Then match [201, 422] contains responseStatus

    Given path 'location-units/libraries'
    And request { id: '#(ecsLibraryId)', name: 'ECS Test Library Central', code: 'ECSL-C', campusId: '#(ecsCampusId)' }
    When method POST
    Then match [201, 422] contains responseStatus

    Given path 'service-points'
    And request { id: '#(ecsServicePointId)', name: 'ECS Central Service Point', code: 'ECS-SP-C', discoveryDisplayName: 'ECS Central Service Point', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then match [201, 422] contains responseStatus

    Given path 'instance-types'
    And request { id: '#(ecsInstanceTypeId)', name: 'ECS Instance Type', code: 'ECSI-T', source: 'local' }
    When method POST
    Then match [201, 422] contains responseStatus

    Given path 'loan-types'
    And request { id: '#(ecsLoanTypeId)', name: 'ECS Loan Type' }
    When method POST
    Then match [201, 422] contains responseStatus

    Given path 'material-types'
    And request { id: '#(ecsMaterialTypeId)', name: 'ECS Material Type' }
    When method POST
    Then match [201, 422] contains responseStatus

    Given path 'holdings-sources'
    And request { id: '#(ecsHoldingsSourceId)', name: 'ECS FOLIO Central' }
    When method POST
    Then match [201, 422] contains responseStatus

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
    Then match [201, 422] contains responseStatus

    # ========== Step 5: Setup inventory data in university tenant ==========
    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(universityLogin.okapitoken)', 'x-okapi-tenant': '#(universityTenant)' }

    Given path 'location-units/institutions'
    And request { id: '#(uniInstitutionId)', name: 'ECS Test Institution University', code: 'ECSI-U' }
    When method POST
    Then match [201, 422] contains responseStatus

    Given path 'location-units/campuses'
    And request { id: '#(uniCampusId)', name: 'ECS Test Campus University', code: 'ECSC-U', institutionId: '#(uniInstitutionId)' }
    When method POST
    Then match [201, 422] contains responseStatus

    Given path 'location-units/libraries'
    And request { id: '#(uniLibraryId)', name: 'ECS Test Library University', code: 'ECSL-U', campusId: '#(uniCampusId)' }
    When method POST
    Then match [201, 422] contains responseStatus

    Given path 'service-points'
    And request { id: '#(uniServicePointId)', name: 'ECS University Service Point', code: 'ECS-SP-U', discoveryDisplayName: 'ECS University Service Point', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then match [201, 422] contains responseStatus

    # Also create the central service point in the university tenant so it is available
    # as a pickup location without relying on cross-tenant Kafka replication.
    # On snapshot/ECS environments the service point is replicated from central to university
    # via Kafka before this step runs, so 422 "Service Point Exists" is a valid outcome.
    Given path 'service-points'
    And request { id: '#(ecsServicePointId)', name: 'ECS Central Service Point', code: 'ECS-SP-C', discoveryDisplayName: 'ECS Central Service Point', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then match [201, 422] contains responseStatus

    Given path 'instance-types'
    And request { id: '#(uniInstanceTypeId)', name: 'ECS Instance Type', code: 'ECSI-T', source: 'local' }
    When method POST
    Then match [201, 422] contains responseStatus

    Given path 'loan-types'
    And request { id: '#(uniLoanTypeId)', name: 'ECS Loan Type' }
    When method POST
    Then match [201, 422] contains responseStatus

    Given path 'material-types'
    And request { id: '#(uniMaterialTypeId)', name: 'ECS Material Type' }
    When method POST
    Then match [201, 422] contains responseStatus

    Given path 'holdings-sources'
    And request { id: '#(uniHoldingsSourceId)', name: 'ECS FOLIO University' }
    When method POST
    Then match [201, 422] contains responseStatus

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
    Then match [201, 422] contains responseStatus

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
