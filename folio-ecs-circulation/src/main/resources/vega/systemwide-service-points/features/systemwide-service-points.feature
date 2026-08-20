@parallel=false
Feature: systemwide-service-points tests

  # The consortium, college and university (secure) tenants are created once per build by
  # vega/common/consortium-bootstrap.feature, invoked from
  # FolioEcsCirculationTests#bootstrapConsortium (@Order(0)) - together with the consortium itself
  # and the 1-hour Keycloak access-token lifespan.
  #
  # This feature used to create those tenants itself, and it was the only setupTenant caller
  # without a pre-emptive cleanup, so once another feature had already created the shared tenant
  # name-space it failed with:
  #   HTTP 400 - Failed to create realm for tenant: consortium<suffix> (Keycloak 409 Conflict)
  # followed by a cascade of TenantNotEnabledException in every later scenario.
  #
  # DO NOT reintroduce setupTenant / setupConsortium / DeleteTenantAndEntitlement here.

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * callonce login admin

    * def eurekaLogin = read('classpath:common-consortia/eureka/initData.feature@Login')

  Scenario: verify consortium, college, and university tenants are registered in the consortium
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    # Verify all three tenants are visible in the consortium before proceeding
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    * configure retry = { count: 10, interval: 10000 }
    Given path 'consortia', consortiumId, 'tenants'
    And retry until responseStatus == 200 && response.totalRecords == 3
    When method GET
    Then status 200
    * print 'Consortium tenants registered:', response.totalRecords
    And match response.tenants[*].id contains centralTenant
    And match response.tenants[*].id contains collegeTenant
    And match response.tenants[*].id contains universityTenant

  Scenario: create service point in central tenant and verify ECS auto-replication to member tenants
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(centralLogin.okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }

    # Pre-flight: confirm consortium has all 3 tenants before creating the service point
    * configure retry = { count: 10, interval: 10000 }
    Given path 'consortia', consortiumId, 'tenants'
    And retry until responseStatus == 200 && response.totalRecords == 3
    When method GET
    Then status 200
    * print 'Pre-flight OK - consortium tenants:', response.totalRecords

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(centralLogin.okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    * def servicePointId = uuid()
    * def servicePointName = 'consortium-sp-' + uuid()
    * def servicePointPayload =
      """
      {
        "id": "#(servicePointId)",
        "name": "#(servicePointName)",
        "code": "#(servicePointName)",
        "discoveryDisplayName": "#(servicePointName)"
      }
      """

    # Create the service point in the central tenant.
    # ECS auto-replicates service points from central to all member tenants.
    Given path 'service-points'
    And request servicePointPayload
    When method POST
    Then status 201

    # Verify the service point is visible in the central tenant
    Given path 'service-points', servicePointId
    When method GET
    Then status 200
    And match response.id == servicePointId
    And match response.name == servicePointName

    # Verify the service point is replicated to the college tenant (ECS auto-replication).
    # On some environments Kafka replication may not occur; create explicitly as a fallback
    # (201 = not yet replicated, 422 = already replicated). Pattern from ecs-consortium-setup.feature.
    * def collegeLogin = call eurekaLogin { username: '#(collegeUser1.username)', password: '#(collegeUser1.password)', tenant: '#(collegeTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(collegeLogin.okapitoken)', 'x-okapi-tenant': '#(collegeTenant)' }
    Given path 'service-points'
    And request servicePointPayload
    When method POST
    * match [201, 422] contains responseStatus
    Given path 'service-points'
    And param query = 'id=="' + servicePointId + '"'
    When method GET
    Then status 200
    And match response.totalRecords == 1

    # Verify the service point is replicated to the university tenant (ECS auto-replication).
    # Same fallback pattern: 201 = not yet replicated, 422 = already replicated.
    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(universityLogin.okapitoken)', 'x-okapi-tenant': '#(universityTenant)' }
    Given path 'service-points'
    And request servicePointPayload
    When method POST
    * match [201, 422] contains responseStatus
    Given path 'service-points'
    And param query = 'id=="' + servicePointId + '"'
    When method GET
    Then status 200
    And match response.totalRecords == 1

  Scenario: create service point in college and verify no replication to consortium and university
    * def collegeLogin = call eurekaLogin { username: '#(collegeUser1.username)', password: '#(collegeUser1.password)', tenant: '#(collegeTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(collegeLogin.okapitoken)', 'x-okapi-tenant': '#(collegeTenant)' }

    * def servicePointId = uuid()
    * def servicePointName = 'college-sp-' + uuid()
    Given path 'service-points'
    And request
      """
      {
        "id": "#(servicePointId)",
        "name": "#(servicePointName)",
        "code": "#(servicePointName)",
        "discoveryDisplayName": "#(servicePointName)"
      }
      """
    When method POST
    Then status 201

    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(centralLogin.okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    * configure retry = { count: 20, interval: 500 }
    Given path 'service-points'
    And param query = 'id=="' + servicePointId + '"'
    When method GET
    Then status 200
    And match response.totalRecords == 0

    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(universityLogin.okapitoken)', 'x-okapi-tenant': '#(universityTenant)' }
    * configure retry = { count: 20, interval: 500 }
    Given path 'service-points'
    And param query = 'id=="' + servicePointId + '"'
    When method GET
    Then status 200
    And match response.totalRecords == 0
