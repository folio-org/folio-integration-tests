Feature: Bootstrap the shared ECS consortium (tenants + consortium registration) exactly once per build

  # ============================================================================
  # WHY THIS FEATURE EXISTS
  #
  # Every feature in this module derives its tenant names from the same three
  # lines of karate-config.js:
  #
  #     centralTenant    = 'consortium' + randomNumbers
  #     collegeTenant    = 'college'    + randomNumbers
  #     universityTenant = 'universitymr1'      <-- FIXED, see below
  #
  # so all of them address ONE shared tenant name-space. Previously each feature
  # deleted and recreated that name-space from its own setup feature, which
  # caused two classes of failure:
  #
  #   1. Keycloak 409 Conflict / HTTP 400 "Failed to create realm for tenant"
  #      when a feature tried to create a tenant another feature had already
  #      created (followed by a cascade of TenantNotEnabledException).
  #   2. Long-running Kafka-driven workflows (mediated requests) losing their
  #      intermediate/central request half-way through, because another feature
  #      tore the central tenant down underneath them.
  #
  # The tenants and the consortium are therefore created HERE, once, before any
  # test feature runs (see FolioEcsCirculationTests#bootstrapConsortium, @Order(0)).
  # The per-suite setup features (ecs-consortium-setup.feature,
  # mediated-requests-consortium-setup.feature) now only add their own
  # inventory, circulation policies and shadow-user capabilities, all of which
  # are additive and safe to run against an already-initialised tenant.
  #
  # DO NOT add tenant creation or tenant deletion to any other feature.
  # Teardown happens once, in destroy-consortia.feature.
  #
  # NOTE ON THE SECURE TENANT: universityTenant is a fixed name because it must
  # equal mod-requests-mediated's SECURE_TENANT_ID (set at deploy time, not
  # readable through any FOLIO API). It cannot be randomised per build, so it is
  # effectively a singleton resource on the environment: two concurrent runs of
  # this module against the same environment will always fight over it. The
  # Jenkins job must hold an environment-level lock (see README / job config).
  # ============================================================================

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

    # setupTenantForConsortia expects the consortium tenant "id" to be the tenant NAME, while
    # setupTenant and DeleteTenantAndEntitlement expect the tenant UUID. Keep both around.
    * def centralTenantUuid = centralTenantId.length == 36 ? centralTenantId : karate.get('centralTenantUuid')
    * eval karate.set('centralTenantUuid', centralTenantUuid)

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

    # ========== Local admin permissions ==========
    # Union of the permission sets the per-suite setup features used to request.
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
      | 'requests-mediated.confirm-item-arrival.post'               |
      | 'requests-mediated.send-item-in-transit.post'               |

    # ========== Step 1: clear leftovers from a previous aborted build ==========
    # This is the ONLY pre-emptive cleanup in the whole module. It runs before any tenant is
    # created and before any test feature starts, so it can never pull a tenant out from under
    # a running workflow.
    #
    # These deletions are best-effort (nothing to delete on a clean environment), so aborted
    # steps are tolerated - but the result is printed, because a silently failed realm deletion
    # here is exactly what surfaces later as "Failed to create realm for tenant: ... 409".
    * configure abortedStepsShouldPass = true
    * def deleteTenant = read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement')
    * print 'consortium-bootstrap: clearing any leftover tenants', centralTenant, collegeTenant, universityTenant
    * call deleteTenant { tenantName: '#(universityTenant)', tenantId: '#(universityTenantId)' }
    * call deleteTenant { tenantName: '#(collegeTenant)', tenantId: '#(collegeTenantId)' }
    * call deleteTenant { tenantName: '#(centralTenant)', tenantId: '#(centralTenantUuid)' }
    * configure abortedStepsShouldPass = false

    # ========== Step 2: create the three tenants ==========
    * call setupTenant { tenant: '#(centralTenant)', tenantId: '#(centralTenantUuid)', user: '#(consortiaAdmin)' }
    * call setupTenant { tenant: '#(universityTenant)', tenantId: '#(universityTenantId)', user: '#(universityUser1)' }
    * call setupTenant { tenant: '#(collegeTenant)', tenantId: '#(collegeTenantId)', user: '#(collegeUser1)' }

    # Extend the Keycloak access-token lifespan to 1 hour now that the realms exist. The mediated
    # request workflow runs for tens of minutes on one set of tokens, so this is required, not
    # cosmetic.
    * call configureAccessTokenTime { 'AccessTokenLifespance': 3600, testTenant: '#(centralTenant)' }
    * call configureAccessTokenTime { 'AccessTokenLifespance': 3600, testTenant: '#(collegeTenant)' }
    * call configureAccessTokenTime { 'AccessTokenLifespance': 3600, testTenant: '#(universityTenant)' }

    # ========== Step 3: create the consortium and register all three tenants ==========
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    * call setupConsortium { tenant: '#(centralTenant)' }

    # setupTenantForConsortia takes the tenant NAME as "id" (mod-consortia keys tenants by name).
    * call setupTenantForConsortia { tenant: '#(centralTenant)', id: '#(centralTenant)', isCentral: true, code: 'CON' }
    * call setupTenantForConsortia { tenant: '#(universityTenant)', id: '#(universityTenant)', isCentral: false, code: 'UNI' }
    * call setupTenantForConsortia { tenant: '#(collegeTenant)', id: '#(collegeTenant)', isCentral: false, code: 'COL' }

    # ========== Step 4: wait for consortium registration to propagate through Kafka ==========
    * configure retry = { count: 20, interval: 30000 }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'x-okapi-consortium-tenant': 'true', 'x-consortium-id': '#(consortiumId)' }
    Given path 'user-tenants'
    And param tenantId = centralTenant
    And retry until responseStatus == 200
    When method GET
    Then status 200

    # All three tenants must be visible in the consortium before any test feature runs.
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
