@parallel=false
Feature: mod-finance integration tests

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * def random = callonce randomMillis
    * def testTenant = 'testfinance' + random
    * def testTenantId = callonce uuid
    * def testAdmin = { tenant: '#(testTenant)', name: 'test-admin', password: 'admin' }
    * def testUser = { tenant: '#(testTenant)', name: 'test-user', password: 'test' }

    # Create tenant and users, initialize data
    * def v = callonce read('classpath:thunderjet/mod-finance/init-finance.feature')

    # Wipe data afterwards
    * configure afterFeature = function() { karate.call('classpath:common/eureka/destroy-data.feature'); }


  Scenario: Allowable encumbrance and expenditure restrictions
    * call read('features/allowable-encumbrance-and-expenditure-restrictions.feature')

  Scenario: Batch transaction API
    * call read('features/batch-transaction-api.feature')

  Scenario: Budget and fund optimistic locking
    * call read('features/budget-and-fund-optimistic-locking.feature')

  Scenario: Budget can be deleted if have only allocation transactions From or To
    * call read('features/budget-can-be-deleted-if-have-only-allocation-transactions-from-or-to.feature')

  Scenario: Budget can not be deleted if have other than allocation transactions
    * call read('features/budget-can-not-be-deleted-if-have-other-than-allocation-transactions.feature')

  Scenario: Budget can not be deleted if have to and from fund in allocation transactions
    * call read('features/budget-can-not-be-deleted-if-have-to-and-from-fund-in-allocation-transactions.feature')

  Scenario: Budget expense classes
    * call read('features/budget-expense-classes.feature')

  Scenario: Should tests budget total amounts calculation
    * call read('features/budgets-totals-calculation.feature')

  Scenario: Budget transfer transactions
    * call read('features/budget-transfer-transactions.feature')

  Scenario: Update budget
    * call read('features/budget-update.feature')

  Scenario: Test when creating budget add expense classes if them provided by user
    * call read('features/create-planned-budget-without-expense-classes-and-current-budget.feature')

  Scenario: Test when creating budget add expense classes if them provided by user
    * call read('features/create-planned-budget-without-expense-classes-when-there-is-no-current-budget.feature')

  Scenario: Test API current budget for fund
    * call read('features/current-budget-for-fund.feature')

  @ignore
  Scenario: Return current fiscal year consider time zone
    * call read('features/curr-fiscal-year-for-ledger-consider-time-zone.feature')

  Scenario: FY finance bulk get/update functionality
    * call read('features/finance-data.feature')

  Scenario: Fiscal year's totals is retrieved when withFinancialSummary parameter is true
    * call read('features/fiscal-year-totals.feature')

  Scenario: Group and ledger transfers after rollover
    * call read('features/group-and-ledger-transfers-after-rollover.feature')

  Scenario: Group expense classes
    * call read('features/group-expense-classes.feature')

  Scenario: Group fiscal year totals
    * call read('features/group-fiscal-year-totals.feature')

  Scenario: Test ledger preview rollover
    * call read('features/ledger-fiscal-year-preview-rollover.feature')

  Scenario: Ledger fiscal year rollover when "Close all current budgets" flag is true
    * call read('features/ledger-fiscal-year-preview-rollover-need-close-budgets.feature')

  Scenario: Verify fault tolerance ledger fiscal year rollover when occurred duplicate encumbrance
    * call read('features/ledger-fiscal-year-rollover-fail-resistance-when-duplicate-encumbrance.feature')

  Scenario: Test ledger fiscal year rollover if one of the POL cost equal 0
    * call read('features/ledger-fiscal-year-rollover-MODFISTO-247.feature')

  Scenario: Verify that order with broken encumbrance will be rolled over successfully
    * call read('features/ledger-fiscal-year-rollover-order-with-broken-encumbrance.feature')

  Scenario: Test ledger rollover pol and system currencies are different
    * call read('features/ledger-fiscal-year-rollover-pol-and-system-currencies-are-different.feature')

  Scenario: Test multiple ledger fiscal year rollovers with different parameters
    * call read('features/ledger-fiscal-year-rollovers-multiple.feature')

  Scenario: Test ledger rollovers sequential
    * call read('features/ledger-fiscal-year-sequential-rollovers.feature')

  Scenario: Test ledger rollovers sequential (skip previous year encumbrance)
    * call read('features/ledger-fiscal-year-skip-previous-year-encumbrance.feature')

  Scenario: Ledger's totals is retrieved when fiscalYear parameter is specified
    * call read('features/ledger-totals.feature')

  Scenario: Budget can not be deleted if have other than allocation transactions
    * call read('features/unopen-order-after-rollover-MODORDERS-542.feature')

  Scenario: Test changing encumbrance from Released to Unreleased
    * call read('features/unrelease-encumbrance.feature')

  Scenario: Budget's totals (available, unavailable, encumbered) is updated when encumbrance's amount is changed but status has not been changed
    * call read('features/update-encumbrance-transactions.feature')

  Scenario: Get funds without providing filter query should take into account acquisition units
    * call read('features/acq-units/verify-get-funds-without-query-where-user-has-units-and-filter-only-by-units.feature')

  Scenario: Get funds where filter is provided should take into account acquisition units
    * call read('features/acq-units/verify-get-funds-with-query-where-user-has-units.feature')

  Scenario: Test creating budget add expense classes from previous budget automatically
    * call read('features/when-creating-budget-add-expense-classes-from-previous-budget-automatically.feature')

  Scenario: Test when creating budget add expense classes if them provided by user
    * call read('features/when-creating-budget-add-expense-classes-if-them-provided-by-user.feature')
