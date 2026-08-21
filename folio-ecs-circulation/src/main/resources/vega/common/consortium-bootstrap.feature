Feature: Bootstrap the shared ECS consortium (tenants + consortium registration) exactly once per build

  # Creates the shared tenants and consortium once before the test suites.
  # The university tenant name must match SECURE_TENANT_ID.

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * callonce login admin

  Scenario: create central, university and college tenants and register the consortium

    * def eurekaLogin = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def setupTenant = read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant')
    * def setupConsortium = read('classpath:common-consortia/eureka/consortium.feature@SetupConsortia')
    * def setupTenantForConsortia = read('classpath:common-consortia/eureka/consortium.feature@SetupTenantForConsortia')
    * def configureAccessTokenTime = read('classpath:common/eureka/keycloak.feature@configureAccessTokenTime')
    * def putCaps = read('classpath:common-consortia/eureka/initData.feature@PutCaps')

    # Keep the central UUID before using the tenant name for entitlements.
    * def centralTenantUuid = centralTenantId.length == 36 ? centralTenantId : karate.get('centralTenantUuid')
    * eval karate.set('centralTenantUuid', centralTenantUuid)

    # Entitlements and consortium registration use the tenant name, not the UUID.
    * eval karate.set('centralTenantId', centralTenant)

    # ========== Modules ==========
    # Union of every module needed by any feature in this module. Tenants are entitled once,
    # so this list must cover systemwide-service-points, staff-slips, ecs-requests AND
    # mediated-requests. Entitling a module a suite does not use is harmless.
    * table modules
      | name                      |
      | 'mod-permissions'         |
      | 'okapi'                   |
      | 'mod-users'               |
      | 'mod-login-keycloak'      |
      | 'mod-inventory-storage'   |
      | 'mod-inventory'           |
      | 'mod-consortia'           |
      | 'mod-circulation-storage' |
      | 'mod-circulation'         |
      | 'mod-circulation-bff'     |
      | 'mod-tlr'                 |
      | 'mod-search'              |
      | 'mod-requests-mediated'   |

    # Shared permissions for all suites; keep this table duplicate-free.
    * table userPermissions
      | name                                                        |
      | 'users.item.post'                                           |
      | 'users.item.get'                                            |
      | 'users.collection.get'                                      |
      | 'usergroups.item.post'                                      |
      | 'perms.permissions.item.post'                               |
      | 'perms.users.item.post'                                     |
      | 'inventory-storage.service-points.item.post'                |
      | 'inventory-storage.service-points.item.get'                 |
      | 'inventory-storage.service-points.collection.get'           |
      | 'inventory-storage.holdings.item.post'                      |
      | 'inventory-storage.items.item.post'                         |
      | 'inventory-storage.items.item.get'                          |
      | 'inventory-storage.items.collection.get'                    |
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
      | 'circulation-storage.requests.collection.get'               |
      | 'circulation-storage.requests.item.get'                     |
      | 'circulation-item.item.get'                                 |
      | 'circulation.check-in-by-barcode.post'                      |
      | 'circulation.requests.item.post'                            |
      | 'circulation.settings.item.post'                            |
      | 'circulation-bff.requests.allowed-service-points.get'       |
      | 'circulation-bff.requests.post'                             |
      | 'circulation-bff.pick-slips.collection.get'                 |
      | 'circulation-bff.search-slips.collection.get'               |
      | 'lost-item-fees-policies.item.post'                         |
      | 'overdue-fines-policies.item.post'                          |
      | 'tlr.settings.put'                                          |
      | 'user-tenants.collection.get'                               |
      | 'search.index.instance-records.reindex.full.post'           |
      | 'requests-mediated.mediated-request.item.post'              |
      | 'requests-mediated.mediated-request.item.get'               |
      | 'requests-mediated.mediated-requests.decline.execute'       |
      | 'requests-mediated.mediated-request.confirm.post'           |
      | 'requests-mediated.confirm-item-arrival.post'               |
      | 'requests-mediated.send-item-in-transit.post'               |

    # Remove leftovers before creating tenants. Resolve IDs by name first.
    * configure abortedStepsShouldPass = true
    * def deleteTenant = read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement')
    * def getTenantIdByName = read('classpath:vega/common/tenant-lookup.feature@getIdByName')
    * print 'consortium-bootstrap: clearing any leftover tenants', centralTenant, collegeTenant, universityTenant
    * def universityLookup = call getTenantIdByName { tenantName: '#(universityTenant)' }
    * def universityIdToDelete = universityLookup.tenantId != null ? universityLookup.tenantId : universityTenantId
    * call deleteTenant { tenantName: '#(universityTenant)', tenantId: '#(universityIdToDelete)' }
    * def collegeLookup = call getTenantIdByName { tenantName: '#(collegeTenant)' }
    * def collegeIdToDelete = collegeLookup.tenantId != null ? collegeLookup.tenantId : collegeTenantId
    * call deleteTenant { tenantName: '#(collegeTenant)', tenantId: '#(collegeIdToDelete)' }
    * def centralLookup = call getTenantIdByName { tenantName: '#(centralTenant)' }
    * def centralIdToDelete = centralLookup.tenantId != null ? centralLookup.tenantId : centralTenantUuid
    * call deleteTenant { tenantName: '#(centralTenant)', tenantId: '#(centralIdToDelete)' }
    * configure abortedStepsShouldPass = false

    # Create the three tenants.
    * call setupTenant { tenant: '#(centralTenant)', tenantId: '#(centralTenantUuid)', user: '#(consortiaAdmin)' }
    * call setupTenant { tenant: '#(universityTenant)', tenantId: '#(universityTenantId)', user: '#(universityUser1)' }
    * call setupTenant { tenant: '#(collegeTenant)', tenantId: '#(collegeTenantId)', user: '#(collegeUser1)' }

    # Use long-lived tokens for the mediated workflow.
    * call configureAccessTokenTime { 'AccessTokenLifespance': 3600, testTenant: '#(centralTenant)' }
    * call configureAccessTokenTime { 'AccessTokenLifespance': 3600, testTenant: '#(collegeTenant)' }
    * call configureAccessTokenTime { 'AccessTokenLifespance': 3600, testTenant: '#(universityTenant)' }

    # Create the consortium and register all three tenants.
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    * call setupConsortium { tenant: '#(centralTenant)' }

    # Consortium tenant IDs are tenant names.
    * call setupTenantForConsortia { tenant: '#(centralTenant)', id: '#(centralTenant)', isCentral: true, code: 'CON' }
    * call setupTenantForConsortia { tenant: '#(universityTenant)', id: '#(universityTenant)', isCentral: false, code: 'UNI' }
    * call setupTenantForConsortia { tenant: '#(collegeTenant)', id: '#(collegeTenant)', isCentral: false, code: 'COL' }

    # Wait for consortium registration to propagate.
    * configure retry = { count: 20, interval: 30000 }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }
    Given path 'user-tenants'
    And param tenantId = centralTenant
    And retry until responseStatus == 200
    When method GET
    Then status 200

    # Confirm all tenants are visible before running tests.
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    * configure retry = { count: 10, interval: 10000 }
    Given path 'consortia', consortiumId, 'tenants'
    And retry until responseStatus == 200 && response.totalRecords == 3
    When method GET
    Then status 200
    And match response.tenants[*].id contains centralTenant
    And match response.tenants[*].id contains collegeTenant
    And match response.tenants[*].id contains universityTenant
    * print 'consortium-bootstrap: consortium ready with', response.totalRecords, 'tenants'

    # Grant shadow-admin capabilities once for all suites.
    * table shadowPermissions
      | name                                                  |
      | 'circulation.requests.item.post'                      |
      | 'circulation.requests.item.get'                       |
      | 'circulation-bff.requests.allowed-service-points.get' |
      | 'circulation-bff.requests.post'                       |
      | 'circulation-bff.pick-slips.collection.get'           |
      | 'circulation-bff.search-slips.collection.get'         |
      | 'inventory.instances.item.get'                        |
      | 'inventory.items.item.get'                            |
      | 'inventory-storage.holdings.item.get'                 |
      | 'user-tenants.collection.get'                         |
      | 'requests-mediated.mediated-request.item.post'        |
      | 'requests-mediated.mediated-request.item.get'         |

    * def userPermissions = shadowPermissions
    * def shadowConsortiaAdminUniversity = { id: '#(consortiaAdmin.id)', tenant: '#(universityTenant)' }
    * def shadowConsortiaAdminCollege = { id: '#(consortiaAdmin.id)', tenant: '#(collegeTenant)' }
    * configure cookies = null
    * call putCaps { tenant: '#(universityTenant)', user: '#(shadowConsortiaAdminUniversity)' }
    * call putCaps { tenant: '#(collegeTenant)', user: '#(shadowConsortiaAdminCollege)' }

    # Restore the central token after granting member capabilities.
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken
    * print 'consortium-bootstrap: shadow consortia_admin capabilities granted in', universityTenant, 'and', collegeTenant
