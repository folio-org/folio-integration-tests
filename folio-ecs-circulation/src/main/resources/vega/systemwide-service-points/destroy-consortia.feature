Feature: Destroy folio-ecs-circulation consortia tenants

  # The ONLY teardown in this module. It deletes exactly the tenant name-space created by
  # vega/common/consortium-bootstrap.feature, and runs once from
  # FolioEcsCirculationTests#tearDown (@AfterAll).
  #
  # Do not add per-feature teardowns. Every feature here shares one tenant name-space, so a second
  # destroy feature (destroy-ecs-requests.feature used to be called as well) deletes a subset of
  # the same tenants - redundant at best, and it widens the window in which a still-running feature
  # or a concurrent job finds the tenants missing. Real per-feature isolation would need per-feature
  # tenant NAMES, which is impossible for the fixed secure tenant (universitymr1 must equal
  # mod-requests-mediated's SECURE_TENANT_ID).
  #
  # The tenant name suffix is pinned for the whole JVM by
  # FolioEcsCirculationTests#runHook (-DrandomNumbers), so the names deleted here are guaranteed to
  # be the names that were created. Before that was pinned, karate-config.js re-evaluated the
  # suffix before every Scenario and this feature deleted names that never existed - leaving
  # Keycloak realms behind that made the next build fail with 409 Conflict.

  Background:
    * url baseUrl
    * configure readTimeout = 90000
    * configure retry = { count: 5, interval: 5000 }
    * call login admin

  Scenario: Destroy created ['consortium', 'college', 'university'] tenants
    * def deleteTenant = read('classpath:common-consortia/eureka/initData.feature@DeleteTenantAndEntitlement')
    * print 'destroy-consortia: deleting', centralTenant, collegeTenant, universityTenant
    * call deleteTenant { tenantName: '#(centralTenant)', tenantId: '#(centralTenantId)' }
    * call deleteTenant { tenantName: '#(collegeTenant)', tenantId: '#(collegeTenantId)' }
    * call deleteTenant { tenantName: '#(universityTenant)', tenantId: '#(universityTenantId)' }
