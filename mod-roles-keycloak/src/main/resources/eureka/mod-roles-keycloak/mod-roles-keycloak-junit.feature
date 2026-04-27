Feature: mod-roles-keycloak integration tests setup

  Background:
    * url baseUrl

    * table modules
      | name                  |
      | 'mod-users-keycloak'  |
      | 'mod-login-keycloak'  |
      | 'mod-roles-keycloak'  |

    * table userPermissions
      | name                                          |
      | 'roles.item.get'                              |
      | 'roles.item.put'                              |
      | 'roles.item.delete'                           |
      | 'roles.item.post'                             |
      | 'roles.collection.get'                        |
      | 'roles.collection.post'                       |
      | 'policies.item.get'                           |
      | 'policies.item.put'                           |
      | 'policies.item.delete'                        |
      | 'policies.item.post'                          |
      | 'policies.collection.post'                    |
      | 'policies.collection.get'                     |
      | 'roles.users.item.get'                        |
      | 'roles.users.item.put'                        |
      | 'roles.users.item.delete'                     |
      | 'roles.users.item.post'                       |
      | 'roles.users.collection.get'                  |
      | 'roles-keycloak.migrations.item.post'         |
      | 'roles-keycloak.migrations.collection.get'    |
      | 'roles-keycloak.migrations.item.get'          |
      | 'roles-keycloak.migrations.item.delete'       |
      | 'roles-keycloak.migrations.errors.get'        |
      | 'capabilities.item.get'                       |
      | 'capabilities.collection.get'                 |
      | 'capability-sets.capabilities.collection.get' |
      | 'capability-sets.item.get'                    |
      | 'capability-sets.collection.get'              |
      | 'role-capabilities.collection.post'           |
      | 'role-capabilities.collection.get'            |
      | 'role-capabilities.collection.put'            |
      | 'role-capabilities.collection.delete'         |
      | 'role-capability-sets.collection.post'        |
      | 'role-capability-sets.collection.get'         |
      | 'role-capability-sets.collection.put'         |
      | 'role-capability-sets.collection.delete'      |
      | 'user-capabilities.collection.post'           |
      | 'user-capabilities.collection.get'            |
      | 'user-capabilities.collection.put'            |
      | 'user-capabilities.collection.delete'         |
      | 'user-capability-sets.collection.post'        |
      | 'user-capability-sets.collection.get'         |
      | 'user-capability-sets.collection.put'         |
      | 'user-capability-sets.collection.delete'      |
      | 'permissions.users.item.get'                  |
      | 'loadable-roles.collection.get'               |
      | 'loadable-roles.item.put'                     |

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
