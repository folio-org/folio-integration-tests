@parallel=false
Feature: edge-orders integration tests

  Background:
    * url baseUrl
    * table modules
      | name                |
      | 'mod-configuration' |
      | 'mod-ebsconet'      |
      | 'mod-gobi'          |
      | 'mod-login'         |
      | 'mod-orders'        |
      | 'mod-organizations' |
      | 'mod-permissions'   |

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name                |
      | 'ebsconet.all'      |
      | 'orders.all'        |
      | 'gobi.all'          |

    * def testTenant = 'test_edge_orders'
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
