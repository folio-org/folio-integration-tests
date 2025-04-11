Feature: mod-login integration tests

  Background:
    * url baseUrl

    * table modules
      | name                |
      | 'mod-permissions'   |
      | 'mod-configuration' |
      | 'mod-users'         |
      | 'mod-login'         |
      | 'mod-feesfines'     |
      | 'mod-inventory'     |

    * table userPermissions
      | name                                    |
      | 'users.item.post'                       |
      | 'owners.item.post'                      |
      | 'accounts.item.post'                    |
      | 'proxiesfor.item.post'                  |
      | 'usergroups.item.post'                  |
      | 'users-bl.item.get'                     |
      | 'users-bl.users-by-username.item.get'   |
      | 'users-bl.transactions.get'             |
      | 'users-bl.transactions-by-username.get' |
      | 'users-bl.item.delete'                  |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')
    * eval java.lang.System.setProperty('mod-users-bl-testUserId', karate.get('userId'))

  Scenario: create admin user for testing purposes
    * def tempUser = testUser
    * def testUser = { tenant: "#(testTenant)", name: '#(testAdmin.name)', password: '#(testAdmin.password)' }
    Given call read('classpath:common/eureka/setup-users.feature@getAuthorizationToken')
    Given call read('classpath:common/eureka/setup-users.feature@createTestUser')
    Given call read('classpath:common/eureka/setup-users.feature@specifyUserCredentials')
    * def testUser = tempUser



