Feature: mod-finance tests

  Background:
    * url baseUrl
    * table modules
      | name              |
      | 'mod-finance'     |
      | 'mod-login'       |
      | 'mod-permissions' |

    * def testTenant = 'testfinance' + runId

    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: '#(generatePassword("test-admin"))'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: '#(generatePassword("test-user"))'}

    * table adminAdditionalPermissions
      | name                                       |
      | 'finance-storage.transactions.item.delete' |

    * table userPermissions
      | name          |
      | 'finance.all' |

    # specify global function login

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    # init test data for orders

  Scenario: transactions
    Given call read('cases/transactions.feature')

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
