Feature: mod-ebsconet integration tests

  Background:
    * url baseUrl
    * table modules
      | name                |
      | 'mod-configuration' |
      | 'mod-ebsconet'      |
      | 'mod-login'         |
      | 'mod-orders'        |
      | 'mod-orders-storage' |
      | 'mod-organizations' |
      | 'mod-permissions'   |
      | 'mod-tags'          |

    * def random = callonce randomMillis
    * def testTenant = 'test_ebsconet' + random
    #* def testTenant = 'test_ebsconet6'
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table userPermissions
      | name           |
      | 'ebsconet.all' |
      | 'orders.all'   |


  Scenario: create tenant and users for testing
    # create tenant and users for testing
    * call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin
    # init global data
    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')

  Scenario: Get Ebsconet Order Line
    Given call read('features/get-ebsconet-order-line.feature')

  Scenario: Update Ebsconet Order Line
    Given call read('features/update-ebsconet-order-line.feature')

  Scenario: Update Ebsconet Order Line mixed format
    Given call read('features/update-mixed-order-line.feature')

  Scenario: Cancel order lines with ebsconet
    Given call read('features/cancel-order-lines-with-ebsconet.feature')

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
