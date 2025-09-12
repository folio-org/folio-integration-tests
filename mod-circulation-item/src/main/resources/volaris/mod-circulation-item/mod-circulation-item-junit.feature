Feature: mod-circulation-item integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-inventory-storage'     |
      | 'mod-circulation-item'      |

    * table adminAdditionalPermissions
      | name                                                              |
      | 'inventory-storage.locations.item.get'                            |
      | 'circulation-item.item.post'                                      |
      | 'circulation-item.item.put'                                       |
      | 'inventory-storage.locations.item.post'                           |


    * table userPermissions
      | name                                                              |
      | 'inventory-storage.locations.item.get'                            |
      | 'circulation-item.item.post'                                      |
      | 'circulation-item.item.put'                                       |
      | 'inventory-storage.locations.item.post'                           |


  Scenario: create tenant and users for testing for mod-circulation-item
    Given call read('classpath:common/eureka/setup-users.feature')

  Scenario: create admin user for testing
    * def tempTestUser = testUser
    * def tempUserPermissions = userPermissions
    * def testUser = { tenant: "#(testTenant)", name: '#(testAdmin.name)', password: '#(testAdmin.password)' }
    * def userPermissions = adminAdditionalPermissions
    Given call read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')
    Given call read('classpath:common/eureka/setup-users.feature@createTestUser')
    Given call read('classpath:common/eureka/setup-users.feature@specifyUserCredentials')
    Given call read('classpath:common/eureka/setup-users.feature@addUserCapabilities')
    * def testUser = tempTestUser
    * def userPermissions = tempUserPermissions