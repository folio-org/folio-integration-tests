Feature: mod-orders integration tests

  Background:
    * url baseUrl
    * table modules
      | name                 |
      | 'mod-finance'        |
      | 'mod-login'          |
      | 'mod-permissions'    |
      | 'mod-finance-storage'|
      | 'mod-configuration'  |

    * def testTenant = 'test_finance' + runId

    * def testAdmin = {tenant: '#(testTenant)', name: 'diku-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name         |
      | 'finance.all' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin
    * callonce read('classpath:global/finances.feature')

  Scenario: Budge's totals (available, unavailable, encumbered) is updated when encumbrance's amount is changed but status has not been changed
    Given call read('update-encumbrance-transactions.feature')

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')