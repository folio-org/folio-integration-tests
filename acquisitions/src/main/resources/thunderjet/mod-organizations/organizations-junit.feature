Feature: mod-organizations integration tests

  Background:
    * url baseUrl

    * table modules
      | name                        |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-orders-storage'        |
      | 'mod-organizations'         |
      | 'mod-organizations-storage' |


    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name                                      |
      | 'organizations.module.all'                |
      | 'organizations-storage.organizations.all' |
      | 'orders-storage.module.all'               |

 # Test tenant name creation:
    * def random = callonce randomMillis
    * def testTenant = 'test_mod_organizations' + '_' + random
    #* def testTenant = 'test_mod_organizations'
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

  Scenario: Create tenant and users for testing
  # Create tenant and users for testing:
    * call read('classpath:common/setup-users.feature')

  Scenario: Init global data
    * call login testAdmin

  # Custom scenario(s):
  Scenario: Create test data
    Given call read('features/create-test-data.feature')

