Feature: mod-users-keycloak integration tests setup

  Background:
    * url baseUrl

    * table modules
      | name                  |
      | 'mod-users-keycloak'  |
      | 'mod-login-keycloak'  |
      | 'mod-roles-keycloak'  |

    * table userPermissions
      | name                                          |
      | 'users-keycloak.item.get'                     |
      | 'users-keycloak.item.post'                    |
      | 'users-keycloak.collection.get'               |
      | 'users-keycloak.item.put'                     |
      | 'users-keycloak.item.delete'                  |
      | 'users-keycloak.migrations.post'              |
      | 'users-keycloak.migrations.get'               |
      | 'users-keycloak.migrations.delete'            |
      | 'users-keycloak.idp-migrations.post'          |
      | 'users-keycloak.idp-migrations.delete'        |
      | 'users-keycloak.password-reset-link.generate' |
      | 'users-keycloak.password-reset-link.reset'    |
      | 'users-keycloak.password-reset-link.validate' |
      | 'users-keycloak.users.permissions.collection.get' |
      | 'users-keycloak.auth-users.item.get'          |
      | 'users-keycloak.auth-users.item.post'         |

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
    * eval java.lang.System.setProperty('mod-users-keycloak-testUserId', karate.get('userId'))
