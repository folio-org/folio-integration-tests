Feature: mod-users-keycloak integration tests setup

  Background:
    * url baseUrl
    * def testUserPermissions = read('classpath:eureka/mod-users-keycloak/data/test-user-permissions.json')
    * def userPermissions = karate.map(testUserPermissions, function(x){ return { name: x } })

    * table modules
      | name                  |
      | 'mod-users-keycloak'  |
      | 'mod-login-keycloak'  |
      | 'mod-roles-keycloak'  |

    * table adminPermissions
      | name              |
      | 'users.item.post' |
      | 'users.item.get'  |

  Scenario: create tenant and users for testing
    * call read('classpath:common/eureka/setup-users.feature')

  Scenario: create admin user for fixture setup
    * call read('classpath:common/eureka/create-additional-user.feature') { testUser: '#(testAdmin)', userPermissions: '#(adminPermissions)' }
