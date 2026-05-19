Feature: mod-users-keycloak integration tests setup

  Background:
    * url baseUrl
    * def testUserPermissions = read('classpath:eureka/mod-users-keycloak/data/test-user-permissions.json')
    * def userPermissions = karate.map(testUserPermissions, function(x){ return { name: x } })

    * table modules
      | name                    |
      | 'mod-users-keycloak'    |
      | 'mod-login-keycloak'    |
      | 'mod-roles-keycloak'    |
      | 'mod-notify'            |

    * table adminPermissions
      | name                |
      | 'users.item.post'   |
      | 'users.item.get'    |
      | 'base-url.item.put' |

  Scenario: create tenant and users for testing
    * call read('classpath:common/eureka/setup-users.feature')

  Scenario: create admin user for fixture setup
    * call read('classpath:common/eureka/create-additional-user.feature') { testUser: '#(testAdmin)', userPermissions: '#(adminPermissions)' }

  Scenario: set FOLIO UI base-url for the tenant
    * call login testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': '*/*' }
    Given path 'base-url'
    And request
      """
      {
        "baseUrl": "#(foliioUiUrl)"
      }
      """
    When method put
    Then status 201
