@ignore
Feature: Common mediated-requests consortium setup (central + university + college tenants, inventory, circulation policies)

  # Sets up a three-tenant consortium (central + university + college) with inventory data,
  # circulation policies, and mod-requests-mediated enabled.
  # The university tenant acts as the "secure" tenant where mediated requests are created.

  Background:
    * url baseUrl
    * configure readTimeout = 600000

  Scenario: setup consortium with central, university, and college tenants
    * def eurekaLogin = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def setupTenant = read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant')
    * def setupConsortium = read('classpath:common-consortia/eureka/consortium.feature@SetupConsortia')
    * def setupTenantForConsortia = read('classpath:common-consortia/eureka/consortium.feature@SetupTenantForConsortia')
    * def putCaps = read('classpath:common-consortia/eureka/initData.feature@PutCaps')
    * def setupCirculationPolicies = read('classpath:vega/ecs-requests/ecs-circulation-policies.feature')

    # Fixed UUIDs for inventory entities
    * callonce read('classpath:vega/mediated-requests/mediated-requests-variables.feature')

    * def centralTenantUuid = centralTenantId.length == 36 ? centralTenantId : karate.get('centralTenantUuid')
    * eval karate.set('centralTenantUuid', centralTenantUuid)
    * eval karate.set('centralTenantId', centralTenant)

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
      | 'mod-tlr'                   |
      | 'mod-search'                |
      | 'mod-requests-mediated'     |

    * table baseUserPermissions
      | name                                                        |
      | 'users.item.post'                                           |
      | 'users.item.get'                                            |
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
      | 'search.index.instance-records.reindex.full.post'           |
      | 'requests-mediated.mediated-request.item.post'              |
      | 'requests-mediated.mediated-request.item.get'               |
      | 'requests-mediated.mediated-requests.decline.execute'       |
      | 'requests-mediated.mediated-request.confirm.post'           |

    * def modules = baseModules
    * def userPermissions = baseUserPermissions

    # ========== Step 1: Create and initialize tenants ==========
    # Pre-emptive cleanup: delete any leftover tenants/realms from a previous failed run.
    * configure abortedStepsShouldPass = true
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') { tenantName: '#(universityTenant)', tenantId: '#(universityTenantId)' }
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') { tenantName: '#(collegeTenant)', tenantId: '#(collegeTenantId)' }
    * call read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement') { tenantName: '#(centralTenant)', tenantId: '#(centralTenantUuid)' }
    * configure abortedStepsShouldPass = false

    * call setupTenant { tenant: '#(centralTenant)', tenantId: '#(centralTenantUuid)', user: '#(consortiaAdmin)' }
    * call setupTenant { tenant: '#(universityTenant)', tenantId: '#(universityTenantId)', user: '#(universityUser1)' }
    * call setupTenant { tenant: '#(collegeTenant)', tenantId: '#(collegeTenantId)', user: '#(collegeUser1)' }

    # ========== Step 2: Create consortium and register tenants ==========
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    * call setupConsortium { tenant: '#(centralTenant)' }
    * call setupTenantForConsortia { tenant: '#(centralTenant)', id: '#(centralTenantId)', isCentral: true, code: 'CON' }
    * call setupTenantForConsortia { tenant: '#(universityTenant)', id: '#(universityTenantId)', isCentral: false, code: 'UNI' }
    * call setupTenantForConsortia { tenant: '#(collegeTenant)', id: '#(collegeTenantId)', isCentral: false, code: 'COL' }

    # Grant shadow consortia_admin in university tenant the permissions needed for cross-tenant operations
    * table uniShadowPermissions
      | name                                            |
      | 'inventory.instances.item.get'                  |
      | 'inventory.items.item.get'                      |
      | 'inventory-storage.holdings.item.get'           |
      | 'user-tenants.collection.get'                   |
      | 'requests-mediated.mediated-request.item.post'  |
      | 'requests-mediated.mediated-request.item.get'   |

    * def userPermissions = uniShadowPermissions
    * def shadowConsortiaAdmin = { id: '#(consortiaAdmin.id)', tenant: '#(universityTenant)' }
    * configure cookies = null
    * call putCaps { tenant: '#(universityTenant)', user: '#(shadowConsortiaAdmin)' }

    # Grant shadow consortia_admin in college tenant
    * table collegeShadowPermissions
      | name                                  |
      | 'inventory.instances.item.get'        |
      | 'inventory.items.item.get'            |
      | 'inventory-storage.holdings.item.get' |
      | 'user-tenants.collection.get'         |

    * def userPermissions = collegeShadowPermissions
    * def shadowConsortiaAdminCollege = { id: '#(consortiaAdmin.id)', tenant: '#(collegeTenant)' }
    * call putCaps { tenant: '#(collegeTenant)', user: '#(shadowConsortiaAdminCollege)' }

    # Re-login as consortia_admin to restore the central tenant okapitoken
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
    And request { id: '#(mrCentralInstitutionId)', name: 'MR Test Institution Central', code: 'MRI-C' }
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request { id: '#(mrCentralCampusId)', name: 'MR Test Campus Central', code: 'MRC-C', institutionId: '#(mrCentralInstitutionId)' }
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request { id: '#(mrCentralLibraryId)', name: 'MR Test Library Central', code: 'MRL-C', campusId: '#(mrCentralCampusId)' }
    When method POST
    Then status 201

    Given path 'service-points'
    And request { id: '#(mrCentralServicePointId)', name: 'MR Central Service Point', code: 'MR-SP-C', discoveryDisplayName: 'MR Central Service Point', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then status 201

    Given path 'instance-types'
    And request { id: '#(mrInstanceTypeId)', name: 'MR Instance Type', code: 'MRI-T', source: 'local' }
    When method POST
    Then status 201

    Given path 'loan-types'
    And request { id: '#(mrLoanTypeId)', name: 'MR Loan Type' }
    When method POST
    Then status 201

    Given path 'material-types'
    And request { id: '#(mrMaterialTypeId)', name: 'MR Material Type' }
    When method POST
    Then status 201

    Given path 'holdings-sources'
    And request { id: '#(mrCentralHoldingsSourceId)', name: 'MR FOLIO Central' }
    When method POST
    Then status 201

    Given path 'locations'
    And request
      """
      {
        "id": "#(mrCentralLocationId)",
        "name": "MR Central Location",
        "code": "MR-LOC-C",
        "institutionId": "#(mrCentralInstitutionId)",
        "campusId": "#(mrCentralCampusId)",
        "libraryId": "#(mrCentralLibraryId)",
        "primaryServicePoint": "#(mrCentralServicePointId)",
        "servicePointIds": ["#(mrCentralServicePointId)"]
      }
      """
    When method POST
    Then status 201

    # ========== Step 5: Setup inventory data in university (secure) tenant ==========
    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(universityLogin.okapitoken)', 'x-okapi-tenant': '#(universityTenant)' }

    Given path 'location-units/institutions'
    And request { id: '#(mrUniInstitutionId)', name: 'MR Test Institution University', code: 'MRI-U' }
    When method POST
    Then status 201

    Given path 'location-units/campuses'
    And request { id: '#(mrUniCampusId)', name: 'MR Test Campus University', code: 'MRC-U', institutionId: '#(mrUniInstitutionId)' }
    When method POST
    Then status 201

    Given path 'location-units/libraries'
    And request { id: '#(mrUniLibraryId)', name: 'MR Test Library University', code: 'MRL-U', campusId: '#(mrUniCampusId)' }
    When method POST
    Then status 201

    Given path 'service-points'
    And request { id: '#(mrUniServicePointId)', name: 'MR University Service Point', code: 'MR-SP-U', discoveryDisplayName: 'MR University Service Point', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then status 201

    # Also create the central service point in the university tenant for pickup availability
    Given path 'service-points'
    And request { id: '#(mrCentralServicePointId)', name: 'MR Central Service Point', code: 'MR-SP-C', discoveryDisplayName: 'MR Central Service Point', pickupLocation: true, holdShelfExpiryPeriod: { duration: 3, intervalId: 'Weeks' } }
    When method POST
    Then match [201, 422] contains responseStatus

    Given path 'instance-types'
    And request { id: '#(mrInstanceTypeId)', name: 'MR Instance Type', code: 'MRI-T', source: 'local' }
    When method POST
    Then status 201

    Given path 'loan-types'
    And request { id: '#(mrLoanTypeId)', name: 'MR Loan Type' }
    When method POST
    Then status 201

    Given path 'material-types'
    And request { id: '#(mrMaterialTypeId)', name: 'MR Material Type' }
    When method POST
    Then status 201

    Given path 'holdings-sources'
    And request { id: '#(mrUniHoldingsSourceId)', name: 'MR FOLIO University' }
    When method POST
    Then status 201

    Given path 'locations'
    And request
      """
      {
        "id": "#(mrUniLocationId)",
        "name": "MR University Location",
        "code": "MR-LOC-U",
        "institutionId": "#(mrUniInstitutionId)",
        "campusId": "#(mrUniCampusId)",
        "libraryId": "#(mrUniLibraryId)",
        "primaryServicePoint": "#(mrCentralServicePointId)",
        "servicePointIds": ["#(mrCentralServicePointId)", "#(mrUniServicePointId)"]
      }
      """
    When method POST
    Then status 201

    # ========== Step 6: Setup circulation policies ==========
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    # Enable ECS TLR feature at consortium level
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true' }
    Given path 'tlr/settings'
    And request { "ecsTlrFeatureEnabled": true, "excludeFromEcsRequestLendingTenantSearch": [] }
    When method PUT
    Then status 204

    * call setupCirculationPolicies { tenant: '#(centralTenant)', okapitoken: '#(okapitoken)', policyLabel: 'MR-Central' }

    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * call setupCirculationPolicies { tenant: '#(universityTenant)', okapitoken: '#(universityLogin.okapitoken)', policyLabel: 'MR-University' }
