Feature: mod-consortia integration tests

  Background:
    * url baseUrl

    * table modules
      | name                        |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-consortia'             |

    * table userPermissions
      | name                        |
      | 'consortia.all'             |


 # Test tenant name creation:
    * def random = callonce randomMillis
    * def testTenant = 'testmodconsortia' + random
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

  Scenario: Create tenant and users for testing
    * call read('classpath:common/setup-users.feature')

  Scenario: Consortia api tests
    Given call read('features/consortium.feature')

  Scenario: Wipe data
    Given call read('classpath:common/destroy-data.feature')
