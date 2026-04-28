Feature: mod-scheduler integration tests setup

  Background:
    * url baseUrl

    * table modules
      | name                  |
      | 'mod-users-keycloak'  |
      | 'mod-login-keycloak'  |
      | 'mod-roles-keycloak'  |
      | 'mod-scheduler'       |

    * table userPermissions
      | name                      |
      | 'scheduler.collection.get' |
      | 'scheduler.item.post'     |
      | 'scheduler.item.get'      |
      | 'scheduler.item.put'      |
      | 'scheduler.item.delete'   |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature@createTenant')
    Given call read('classpath:common/eureka/setup-users.feature@createEntitlement')
    Given call read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')
    Given call read('classpath:common/eureka/setup-users.feature@createTestUser')

    * def userName = testUser.name
    * def userId = karate.get('userId')
    * def password = testUser.password
    * def accesstoken = karate.get('accessToken')
    * configure retry = { count: 20, interval: 5000 }
    Given path 'authn', 'credentials'
    And headers {'x-okapi-tenant':'#(testTenant)', 'x-okapi-token': '#(accesstoken)'}
    And request {username: '#(userName)', "userId": '#(userId)', password :'#(password)'}
    And retry until responseStatus == 201
    When method POST
    Then status 201

    Given call read('classpath:common/eureka/setup-users.feature@addUserCapabilities')
