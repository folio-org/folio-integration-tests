Feature: mod-login-keycloak integration tests setup

  Background:
    * url baseUrl

    * table modules
      | name                  |
      | 'mod-users-keycloak'  |
      | 'mod-login-keycloak'  |
      | 'mod-roles-keycloak'  |

    * table userPermissions
      | name                                  |
      | 'login.event.collection.post'         |
      | 'login.event.collection.get'          |
      | 'login.event.delete'                  |
      | 'login.attempts.item.get'             |
      | 'login.item.post'                     |
      | 'login.item.delete'                   |
      | 'login.password.validate'             |
      | 'login.password-reset-action.post'    |
      | 'login.password-reset-action.get'     |
      | 'login.password-reset.post'           |
      | 'login.credentials-existence.get'     |
      | 'auth.token.post'                     |
      | 'auth.refreshtoken.post'              |
      | 'auth.token.sign.post'                |
      | 'auth.token.refresh.post'             |

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
