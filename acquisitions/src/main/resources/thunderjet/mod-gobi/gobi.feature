Feature: mod-gobi integration tests

  Background:
    * url baseUrl

    * table modules
      | name                        |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-organizations'         |

    * table userPermissions
      | name                                      |


 # Test tenant name creation:
    * def random = callonce randomMillis
    * def testTenant = 'test_mod_gobi' + '_' + random
    #* def testTenant = 'test_mod_gobi'
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

  Scenario: Create tenant and users for testing
  # Create tenant and users for testing:
    * call read('classpath:common/setup-users.feature')

  Scenario: GOBI api tests
    Given call read('features/gobi-api-tests.feature')

  Scenario: Wipe data
    Given call read('classpath:common/destroy-data.feature')