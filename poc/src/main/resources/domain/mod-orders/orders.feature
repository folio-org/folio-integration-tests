Feature: mod-orders tests

  Background:
    * url baseUrl
    * table modules
      | name                |
      | 'mod-orders'        |
      | 'mod-login'         |
      | 'mod-permissions'   |
      | 'mod-configuration' |

    * def testTenant = 'test_orders' + runId

    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table userPermissions
      | name         |
      | 'orders.all' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:common/global-inventory.feature')
    * callonce read('classpath:common/global-finances.feature')
    * callonce read('classpath:common/global-organizations.feature')

  Scenario: create composite orders
    Given call read('cases/composite-orders.feature')

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
