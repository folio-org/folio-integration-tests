@parallel=false
Feature: systemwide-service-points tests

  Background:
    * url baseUrl
    * configure readTimeout = 600000
    * callonce login admin

    * table modules
      | name                    |
      | 'mod-permissions'       |
      | 'okapi'                 |
      | 'mod-users'             |
      | 'mod-login'             |
      | 'mod-inventory-storage' |
      | 'mod-consortia'         |

    * table userPermissions
      | name                                          |
      | 'users.item.post'                             |
      | 'usergroups.item.post'                        |
      | 'perms.permissions.item.post'                 |
      | 'perms.users.item.post'                       |
      | 'users.collection.get'                        |
      | 'users.item.get'                              |
      | 'inventory-storage.service-points.item.post'  |
      | 'inventory-storage.service-points.collection.get' |

    * def eurekaLogin = read('classpath:common-consortia/eureka/initData.feature@Login')
    * def setupTenant = read('classpath:common-consortia/eureka/tenant-and-local-admin-setup.feature@SetupTenant')
    * def setupConsortium = read('classpath:common-consortia/eureka/consortium.feature@SetupConsortia')
    * def setupTenantForConsortia = read('classpath:common-consortia/eureka/consortium.feature@SetupTenantForConsortia')
    * def configureAccessTokenTime = read('classpath:common/eureka/keycloak.feature@configureAccessTokenTime')

  Scenario: create and initialize consortium, college, and university tenants
    * call setupTenant { tenant: '#(centralTenant)', tenantId: '#(centralTenantId)', user: '#(consortiaAdmin)' }
    * call setupTenant { tenant: '#(collegeTenant)', tenantId: '#(collegeTenantId)', user: '#(collegeUser1)' }
    * call setupTenant { tenant: '#(universityTenant)', tenantId: '#(universityTenantId)', user: '#(universityUser1)' }

    # Extend the Keycloak access-token lifespan to 2 hours AFTER tenant setup so the realms exist.
    # This prevents token expiry during long async waits (service-point replication, etc.)
    * call configureAccessTokenTime { 'AccessTokenLifespance': 7200, testTenant: '#(centralTenant)' }
    * call configureAccessTokenTime { 'AccessTokenLifespance': 7200, testTenant: '#(collegeTenant)' }
    * call configureAccessTokenTime { 'AccessTokenLifespance': 7200, testTenant: '#(universityTenant)' }

  Scenario: create consortium and register consortium, college, and university tenants
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    * call setupConsortium { tenant: '#(centralTenant)' }
    * call setupTenantForConsortia { tenant: '#(centralTenant)', id: '#(centralTenantId)', isCentral: true, code: 'CON' }
    * call setupTenantForConsortia { tenant: '#(collegeTenant)', id: '#(collegeTenantId)', isCentral: false, code: 'COL' }
    * call setupTenantForConsortia { tenant: '#(universityTenant)', id: '#(universityTenantId)', isCentral: false, code: 'UNI' }

    # Verify all three tenants are visible in the consortium before proceeding
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    * configure retry = { count: 10, interval: 10000 }
    Given path 'consortia', consortiumId, 'tenants'
    And retry until response.totalRecords == 3
    When method GET
    Then status 200
    * print 'Consortium tenants registered:', response.totalRecords
    And match response.tenants[*].id contains centralTenant
    And match response.tenants[*].id contains collegeTenant
    And match response.tenants[*].id contains universityTenant

  Scenario: create service point in consortium and verify replication to college and university
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(centralLogin.okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }

    # Pre-flight: confirm consortium has all 3 tenants before creating the service point
    * configure retry = { count: 10, interval: 10000 }
    Given path 'consortia', consortiumId, 'tenants'
    And retry until response.totalRecords == 3
    When method GET
    Then status 200
    * print 'Pre-flight OK - consortium tenants:', response.totalRecords

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(centralLogin.okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    * def servicePointId = uuid()
    * def servicePointName = 'consortium-sp-' + uuid()
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

    # JS polling loop: re-login on every attempt so tokens are always fresh,
    # and log the actual response for diagnostics when replication is slow.
    # NOTE: must pass a single object arg to avoid Karate's list-call semantics.
    * def pollForServicePoint =
      """
      function(args) {
        var loginConfig = args.loginConfig;
        var spId = args.spId;
        var maxAttempts = 80;
        var intervalMs  = 15000;
        for (var i = 0; i < maxAttempts; i++) {
          var result = karate.call(
            'classpath:vega/systemwide-service-points/get-service-point.feature@GetServicePoint',
            { username: loginConfig.username, password: loginConfig.password,
              tenant: loginConfig.tenant, servicePointId: spId }
          );
          karate.log('Attempt', i + 1, '- tenant:', loginConfig.tenant,
                     'totalRecords:', result.totalRecords);
          if (result.totalRecords == 1) {
            return result;
          }
          if (i < maxAttempts - 1) {
            java.lang.Thread.sleep(intervalMs);
          }
        }
        karate.fail('Service point ' + spId + ' not replicated to tenant '
                    + loginConfig.tenant + ' after ' + maxAttempts + ' attempts');
      }
      """

    * def collegeResult = call pollForServicePoint { loginConfig: { username: '#(collegeUser1.username)', password: '#(collegeUser1.password)', tenant: '#(collegeTenant)' }, spId: '#(servicePointId)' }
    And match collegeResult.servicepoints[0].id == servicePointId
    And match collegeResult.servicepoints[0].name == servicePointName

    * def universityResult = call pollForServicePoint { loginConfig: { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }, spId: '#(servicePointId)' }
    And match universityResult.servicepoints[0].id == servicePointId
    And match universityResult.servicepoints[0].name == servicePointName

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
