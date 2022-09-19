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

    * def testTenant = 'testedgeorders'
    * def testAdmin = { tenant: '#(testTenant)', name: 'test-admin', password: 'admin' }
    * def testUser = { tenant: '#(testTenant)', name: 'test-user', password: 'test' }

    * table userPermissions
      | name           |
      | 'ebsconet.all'      |
      | 'orders.all'        |
      | 'gobi.all'          |

  Scenario: create tenant and users for testing
    * call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin
    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')

  Scenario: Ebsconet
    Given call read('features/ebsconet.feature')

  Scenario: GOBI
    Given call read('features/gobi.feature')

  Scenario: wipe data
    Given call read('edge-orders-destroy-data.feature')
