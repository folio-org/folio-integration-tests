Feature: mod-invoice integration tests

  Background:
    * url baseUrl
    * table modules
      | name                |
      | 'mod-invoice'       |
      | 'mod-login'         |
      | 'mod-permissions'   |
      | 'mod-configuration' |

    * def random = callonce randomMillis
    * def testTenant = 'test_invoices' + random

    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name          |
      | 'invoice.all' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')

  Scenario: Prorated adjustments special cases
    Given call read('features/prorated-adjustments-special-cases.feature')

  Scenario: Check remaining amount upon invoice approval
    Given call read('features/check-remaining-amount-upon-invoice-approval.feature')

  Scenario: Check invoice and invoice lines deletion restrictions
    Given call read('features/check-invoice-and-invoice-lines-deletion-restrictions.feature')

  Scenario: Checking that voucher lines are created taking into account the expense classes
    Given call read('features/create-voucher-lines-honor-expense-classes.feature')

  Scenario: Update exchange rate after invoice approval
    Given call read('features/exchange-rate-update-after-invoice-approval.feature')

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
