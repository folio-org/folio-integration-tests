Feature: mod-orders integration tests

  Background:
    * url baseUrl
    * table modules
      | name                |
      | 'mod-invoice'       |
      | 'mod-finance'       |
      | 'mod-orders'        |
      | 'mod-login'         |
      | 'mod-permissions'   |
      | 'mod-configuration' |

    * def random = callonce randomMillis
    * def testTenant = 'test_cross_modules' + random

    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name          |
      | 'invoice.all' |
      | 'orders.all'  |
      | 'finance.all' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')

  Scenario: create order with invoice that have enough money in budget
    Given call read('features/create-order-with-invoice-that-has-enough-money.feature')

  Scenario: order invoice relation
    Given call read('features/order-invoice-relation.feature')

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
