Feature: mod-gobi integration tests

  Background:
    * url baseUrl

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'okapi'                     |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-pubsub'                |
      | 'mod-audit'                 |
      | 'mod-gobi'                  |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-organizations'         |
      | 'mod-organizations-storage' |
      | 'mod-organizations'         |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-search'                |
      | 'mod-source-record-manager' |
      | 'mod-entities-links'        |

    * table userPermissions
      | name                        |


 # Test tenant name creation:
    * def random = callonce randomMillis
    * def testTenant = 'testmodgobi' + random
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

  Scenario: Create tenant and users for testing
  # Create tenant and users for testing:
    * call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/organizations.feature')

  Scenario: GOBI api tests
    Given call read('features/gobi-api-tests.feature')

  Scenario: Find holdings by location and instance
    Given call read('features/find-holdings-by-location-and-instance.feature')

  Scenario: Wipe data
    Given call read('classpath:common/destroy-data.feature')
