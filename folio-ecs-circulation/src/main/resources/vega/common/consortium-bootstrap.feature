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
    * def putCaps = read('classpath:common-consortia/eureka/initData.feature@PutCaps')

    # setupTenant and DeleteTenantAndEntitlement expect the central tenant UUID, so stash it as
    # centralTenantUuid before overwriting centralTenantId below.
    * def centralTenantUuid = centralTenantId.length == 36 ? centralTenantId : karate.get('centralTenantUuid')
    * eval karate.set('centralTenantUuid', centralTenantUuid)

    # centralTenantId must hold the central tenant NAME for the rest of this scenario.
    # InstallApplications (called by setupTenant) reads karate.get('centralTenantId') and passes it
    # through as the '&tenantParameters=...,centralTenantId=<value>' entitlement parameter, which
    # FOLIO expects to be the tenant name - the same string used as x-okapi-tenant. Entitling the
    # member tenants with a UUID here silently breaks the ECS wiring. setupTenantForConsortia
    # likewise keys consortium tenants by name.
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

    # ========== Local admin permissions ==========
    # Union of the permission sets the per-suite setup features used to request.
    #
    # THIS LIST MUST CONTAIN NO DUPLICATES, AND NONE OF THE PERMISSIONS THAT SetupTenant ALREADY
    # ADDS ITSELF. SetupTenant computes
    #     userPermissions = requiredCapabilitiesForConsortia.concat(<this list>)
    # and PutCaps then loops until 'capabilityIds.length == permissions.length'. Duplicates make
    # that condition unsatisfiable (the deduplicated capability lookup returns fewer ids than the
    # requested list has entries), so PutCaps burns all 30 retries at 30s each - 15 minutes per
    # tenant - logs the misleading
    #     ***** Not all capabilities found. Missing 0 capabilities *****
    # and then proceeds with the correct capabilities anyway. The old per-suite lists repeated four
    # consortia.* permissions from requiredCapabilitiesForConsortia (sharing-instances.item.post,
    # sharing-instances.collection.get, user-tenants.collection.get, user-tenants.item.post) plus
    # circulation-storage.request-policies.item.post twice: 88 requested, 83 distinct, 45 minutes
    # of dead time per build across three tenants. Those five entries are deliberately absent here.
    #
    # requiredCapabilitiesForConsortia already covers every consortia.* and tags.* permission, so do
    # not add any of those below. 'user-tenants.collection.get' (mod-users) is NOT part of it and is
    # required.
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

    # ========== Step 5: grant shadow consortia_admin capabilities, ONCE ==========
    # The shadow consortia_admin (same user id as the central consortia_admin, projected into each
    # member tenant by the primary-affiliation propagation triggered in Step 3) needs cross-tenant
    # read/write capabilities. This grant lives HERE, and only here, because PutCaps issues a plain
    # POST /users/capabilities, which is NOT idempotent: mod-roles-keycloak answers
    #     400 EntityExistsException "Relation already exists for user=... and capabilities=[...]"
    # if any single capability in the payload is already assigned to the user.
    #
    # This used to be done from the per-suite setups, and it broke deterministically. Test order is
    # mediated-requests (@Order 1) -> staff-slips (@Order 3) -> ecs-requests (@Order 4);
    # mediated-requests-consortium-setup.feature granted
    #     inventory.instances.item.get, inventory.items.item.get,
    #     inventory-storage.holdings.item.get, user-tenants.collection.get
    # to the university shadow admin, and ecs-consortium-setup.feature - callonce'd by BOTH
    # staff-slips and ecs-requests, and callonce is scoped per feature file, so it runs twice -
    # then re-POSTed a superset containing those same four. Both later suites died in setup on the
    # 400 above. Nothing was wrong with the tenants; the grant was simply replayed.
    #
    # THE LIST BELOW IS THE UNION OF EVERY SUITE'S SHADOW-USER REQUIREMENTS AND MUST CONTAIN NO
    # DUPLICATES. Add new shadow capabilities here, never in a per-suite setup feature. See also
    # the duplicate-permission warning on the userPermissions table above - PutCaps loops until
    # 'capabilityIds.length == permissions.length', which a duplicated entry makes unsatisfiable.
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

    # PutCaps calls getAuthorizationToken for the member tenant, overwriting okapitoken - restore
    # the central token so anything running after this scenario still addresses the central tenant.
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken
    * print 'consortium-bootstrap: shadow consortia_admin capabilities granted in', universityTenant, 'and', collegeTenant
