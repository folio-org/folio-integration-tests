Feature: mod-okapi-facade integration tests setup

  Background:
    * url baseUrl
    * configure retry = { count: 10, interval: 5000 }

    * table modules
      | name                 |
      | 'mod-users-keycloak' |
      | 'mod-login-keycloak' |
      | 'mod-roles-keycloak' |
      | 'mod-okapi-facade'   |

    * table userPermissions
      | name                                  |
      | 'okapi.proxy.tenants.modules.list'    |
      | 'okapi.proxy.tenants.interfaces.list' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature@createTenant')
    Given call read('classpath:common/eureka/setup-users.feature@createEntitlement')
    Given call read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')
    Given call read('classpath:common/eureka/setup-users.feature@createTestUser')

    * def userName = testUser.name
    * def userId = karate.get('userId')
    * def password = testUser.password
    * def accesstoken = karate.get('accessToken')
    Given path 'authn', 'credentials'
    And headers {'x-okapi-tenant':'#(testTenant)', 'x-okapi-token': '#(accesstoken)'}
    And request {username: '#(userName)', "userId": '#(userId)', password :'#(password)'}
    And retry until responseStatus == 201
    When method POST
    Then status 201

    Given call read('classpath:common/eureka/setup-users.feature@addUserCapabilities')
