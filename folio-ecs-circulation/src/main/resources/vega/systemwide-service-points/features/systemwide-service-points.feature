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

  Scenario: create and initialize consortium, college, and university tenants
    * call setupTenant { tenant: '#(centralTenant)', tenantId: '#(centralTenantId)', user: '#(consortiaAdmin)' }
    * call setupTenant { tenant: '#(collegeTenant)', tenantId: '#(collegeTenantId)', user: '#(collegeUser1)' }
    * call setupTenant { tenant: '#(universityTenant)', tenantId: '#(universityTenantId)', user: '#(universityUser1)' }

  Scenario: create consortium and register consortium, college, and university tenants
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
    * def okapitoken = centralLogin.okapitoken

    * call setupConsortium { tenant: '#(centralTenant)' }
    * call setupTenantForConsortia { tenant: '#(centralTenant)', id: '#(centralTenantId)', isCentral: true, code: 'CON' }
    * call setupTenantForConsortia { tenant: '#(collegeTenant)', id: '#(collegeTenantId)', isCentral: false, code: 'COL' }
    * call setupTenantForConsortia { tenant: '#(universityTenant)', id: '#(universityTenantId)', isCentral: false, code: 'UNI' }

  Scenario: create service point in consortium and verify replication to college and university
    * def centralLogin = call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenant)' }
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

    * def collegeLogin = call eurekaLogin { username: '#(collegeUser1.username)', password: '#(collegeUser1.password)', tenant: '#(collegeTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(collegeLogin.okapitoken)', 'x-okapi-tenant': '#(collegeTenant)' }
    * configure retry = { count: 20, interval: 500 }
    Given path 'service-points'
    And param query = 'id=="' + servicePointId + '"'
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.servicepoints[0].id == servicePointId
    And match response.servicepoints[0].name == servicePointName

    * def universityLogin = call eurekaLogin { username: '#(universityUser1.username)', password: '#(universityUser1.password)', tenant: '#(universityTenant)' }
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(universityLogin.okapitoken)', 'x-okapi-tenant': '#(universityTenant)' }
    * configure retry = { count: 20, interval: 500 }
    Given path 'service-points'
    And param query = 'id=="' + servicePointId + '"'
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match response.servicepoints[0].id == servicePointId
    And match response.servicepoints[0].name == servicePointName

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
