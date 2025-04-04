@parallel=false
Feature: edge-orders integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-organizations-storage' |
      | 'mod-organizations'         |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-ebsconet'              |
      | 'mod-gobi'                  |

    * table userPermissions
      | name           |
      | 'ebsconet.all' |
      | 'orders.all'   |
      | 'gobi.all'     |

    * def testTenant = 'testedgeorders'
    * def testAdmin = { tenant: '#(testTenant)', name: 'test-admin', password: 'admin' }
    * def testUser = { tenant: '#(testTenant)', name: 'test-user', password: 'test' }

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature') { testTenant: '#(testTenant)', testAdmin: #(testAdmin), testUser: #(testUser) }

  Scenario: init global data
    * call login testAdmin
    * callonce read('classpath:global/inventory.feature') { testAdmin: #(testAdmin) }
    * callonce read('classpath:global/configuration.feature') { testAdmin: #(testAdmin) }
    * callonce read('classpath:global/finances.feature') { testAdmin: #(testAdmin) }
    * callonce read('classpath:global/organizations.feature') { testAdmin: #(testAdmin) }
