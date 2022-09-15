Feature: mod-finance integration tests

  Background:
    * url baseUrl
    * table modules
      | name                    |
      | 'mod-inventory-storage' |
      | 'mod-orders-storage'    |
      | 'mod-orders'            |
      | 'mod-finance-storage'   |
      | 'mod-finance'           |
      | 'mod-login'             |
      | 'mod-permissions'       |
      | 'mod-configuration'     |

    * def random = callonce randomMillis
    * def testTenant = 'test_finance' + random
    #* def testTenant = 'test_finance'
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table adminAdditionalPermissions
      | name                                         |
      | 'acquisitions-units-storage.units.item.post' |
      | 'acquisitions-units-storage.units.item.put'  |
      | 'acquisitions-units-storage.units.item.get'  |
      | 'finance.module.all'                         |
      | 'finance.all'                                |



    * table userPermissions
      | name                                         |
      | 'finance.all'                                |
      | 'finance.module.all'                         |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/inventory.feature')

  Scenario: Budget's totals (available, unavailable, encumbered) is updated when encumbrance's amount is changed but status has not been changed
    Given call read('features/update-encumbrance-transactions.feature')

  Scenario: Ledger's totals is retrieved when fiscalYear parameter is specified
    Given call read('features/ledger-totals.feature')

  Scenario: Fiscal year's totals is retrieved when withFinancialSummary parameter is true
    Given call read('features/fiscal-year-totals.feature')

  Scenario: Group fiscal year totals
    Given call read('features/group-fiscal-year-totals.feature')

  Scenario: Budget expense classes
    Given call read('features/budget-expense-classes.feature')

  Scenario: Group expense classes
     Given call read('features/group-expense-classes.feature')

  Scenario: Budget transfer transactions
    Given call read('features/budget-transfer-transactions.feature')

  Scenario: Update budget
    Given call read('features/budget-update.feature')

  Scenario: Test API current budget for fund
    Given call read('features/current-budget-for-fund.feature')

  Scenario: Test API transactions summaries
    Given call read('features/transaction-summaries-crud.feature')

  Scenario: Test changing encumbrance from Released to Unreleased
    Given call read('features/unrelease-encumbrance.feature')

  Scenario: Test creating budget add expense classes from previous budget automatically
    Given call read('features/When-creating-budget-add-expense-classes-from-previous-budget-automatically.feature')

  Scenario: Test when creating budget add expense classes if them provided by user
    Given call read('features/When-creating-budget-add-expense-classes-if-them-provided-by-user.feature')

  Scenario: Test when creating budget add expense classes if them provided by user
    Given call read('features/Create-planned-budget-without-expense-classes-when-there-is-no-current-budget.feature')

  Scenario: Test when creating budget add expense classes if them provided by user
    Given call read('features/create-planned-budget-without-expense-classes-and-current-budget.feature')

  Scenario: Test ledger rollover
    Given call read('features/ledger-fiscal-year-rollover.feature')

  Scenario: Test ledger preview rollover
    Given call read('features/ledger-fiscal-year-preview-rollover.feature')

  Scenario: Test ledger rollover pol and system currencies are different
    Given call read('features/ledger-fiscal-year-rollover-pol-and-system-currencies-are-different.feature')

  Scenario: Get funds where filter is provided should take into account acquisition units
    Given call read('features/acq-units/verify-get-funds-with-query-where-user-has-units.feature')

  Scenario: Get funds without providing filter query should take into account acquisition units
    Given call read('features/acq-units/verify-get-funds-without-query-where-user-has-units-and-filter-only-by-units.feature')

  Scenario: Budget can be deleted if have only allocation transactions From or To
    Given call read('features/budget-can-be-deleted-if-have-only-allocation-transactions-From-or-To.feature')

  Scenario: Budget can not be deleted if have other than allocation transactions
    Given call read('features/budget-can-not-be-deleted-if-have-other-than-allocation-transactions.feature')

  Scenario: Test ledger fiscal year rollover if one of the POL cost equal 0
    Given call read('features/ledger-fiscal-year-rollover-MODFISTO-247.feature')

  Scenario: Budget can not be deleted if have other than allocation transactions
    Given call read('features/unopen-order-after-rollover-MODORDERS-542.feature')
#  Scenario: Return current fiscal year consider time zone
#    Given call read('features/curr-fiscal-year-for-ledger-consider-time-zone.feature')

  Scenario: Should tests budget total amounts calculation
    Given call read('features/budgets-totals-calculation.feature')

  Scenario: Test multiple ledger fiscal year rollovers with different parameters
    Given call read('features/ledger-fiscal-year-rollovers-multiple.feature')

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
