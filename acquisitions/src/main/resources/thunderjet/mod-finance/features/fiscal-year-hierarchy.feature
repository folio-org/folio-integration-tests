# For MODFIN-387
Feature: Fiscal year hierarchy

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    # Flattens all funds of all ledgers (grouped and ungrouped) into one list
    * def collectFunds =
    """
    function(hierarchies) {
      var result = [];
      hierarchies.forEach(function(h) {
        (h.funds || []).forEach(function(f) { result.push(f); });
        (h.groups || []).forEach(function(g) {
          (g.funds || []).forEach(function(f) { result.push(f); });
        });
      });
      return result;
    }
    """
    # Collects all budget expense classes from a list of budgets
    * def collectExpenseClasses =
    """
    function(budgets) {
      var result = [];
      budgets.forEach(function(b) {
        (b.budgetExpenseClasses || []).forEach(function(e) { result.push(e); });
      });
      return result;
    }
    """


  Scenario: Fiscal year without ledgers returns empty hierarchy
    * def fiscalYearId = call uuid
    * def v = call createFiscalYear { id: '#(fiscalYearId)', code: 'FYHIERA2061', periodStart: '2061-01-01', periodEnd: '2061-12-31', series: 'FYHIERA' }

    Given path 'finance/fiscal-year-hierarchy'
    And param fiscalYearId = fiscalYearId
    When method GET
    Then status 200
    And match response.fiscalYearHierarchies == '#[0]'
    And match response.totalRecords == 0


  # The storage hierarchy view is built from budgets, so ledgers and funds without a budget in the fiscal year are not returned
  Scenario: Fiscal year and ledger only - empty hierarchy returned
    * def fiscalYearId = call uuid
    * def ledgerId = call uuid
    * def v = call createFiscalYear { id: '#(fiscalYearId)', code: 'FYHIERB2062', periodStart: '2062-01-01', periodEnd: '2062-12-31', series: 'FYHIERB' }
    * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fiscalYearId)' }

    Given path 'finance/fiscal-year-hierarchy'
    And param fiscalYearId = fiscalYearId
    When method GET
    Then status 200
    And match response.fiscalYearHierarchies == '#[0]'
    And match response.totalRecords == 0


  Scenario: Fiscal year, ledger and fund without budget - empty hierarchy returned
    * def fiscalYearId = call uuid
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def v = call createFiscalYear { id: '#(fiscalYearId)', code: 'FYHIERC2063', periodStart: '2063-01-01', periodEnd: '2063-12-31', series: 'FYHIERC' }
    * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fiscalYearId)' }
    * def v = call createFund { id: '#(fundId)', ledgerId: '#(ledgerId)' }

    Given path 'finance/fiscal-year-hierarchy'
    And param fiscalYearId = fiscalYearId
    When method GET
    Then status 200
    And match response.fiscalYearHierarchies == '#[0]'
    And match response.totalRecords == 0


  Scenario: Hierarchy without groups - fund and budget returned as ungrouped
    * def fiscalYearId = call uuid
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def budgetId = call uuid
    * def v = call createFiscalYear { id: '#(fiscalYearId)', code: 'FYHIERD2064', periodStart: '2064-01-01', periodEnd: '2064-12-31', series: 'FYHIERD' }
    * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fiscalYearId)' }
    * def v = call createFund { id: '#(fundId)', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', fiscalYearId: '#(fiscalYearId)', allocated: 1000 }

    Given path 'finance/fiscal-year-hierarchy'
    And param fiscalYearId = fiscalYearId
    When method GET
    Then status 200
    And match response.fiscalYearHierarchies == '#[1]'
    * def h = response.fiscalYearHierarchies[0]
    And match h.ledgerId == ledgerId
    And match h.groups == '##[0]'
    And match h.funds == '#[1]'
    And match h.funds[0].fundId == fundId
    And match h.funds[0].budget.budgetId == budgetId
    And match h.funds[0].budget.budgetStatus == 'Active'


  Scenario: Hierarchy without expense classes - fund grouped, budget has no expense classes
    * def fiscalYearId = call uuid
    * def ledgerId = call uuid
    * def groupId = call uuid
    * def fundId = call uuid
    * def budgetId = call uuid
    * def v = call createFiscalYear { id: '#(fiscalYearId)', code: 'FYHIERE2065', periodStart: '2065-01-01', periodEnd: '2065-12-31', series: 'FYHIERE' }
    * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fiscalYearId)' }

    Given path 'finance/groups'
    And request { id: '#(groupId)', code: '#(groupId)', name: '#(groupId)', status: 'Active' }
    When method POST
    Then status 201

    * def v = call createFund { id: '#(fundId)', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', fiscalYearId: '#(fiscalYearId)', allocated: 1000 }

    Given path 'finance/group-fund-fiscal-years'
    And request { groupId: '#(groupId)', fundId: '#(fundId)', fiscalYearId: '#(fiscalYearId)', budgetId: '#(budgetId)' }
    When method POST
    Then status 201

    Given path 'finance/fiscal-year-hierarchy'
    And param fiscalYearId = fiscalYearId
    When method GET
    Then status 200
    And match response.fiscalYearHierarchies == '#[1]'
    * def h = response.fiscalYearHierarchies[0]
    And match h.ledgerId == ledgerId
    And match h.funds == '##[0]'
    And match h.groups == '#[1]'
    And match h.groups[0].groupId == groupId
    And match h.groups[0].funds == '#[1]'
    And match h.groups[0].funds[0].fundId == fundId
    And match h.groups[0].funds[0].budget.budgetId == budgetId
    And match h.groups[0].funds[0].budget.budgetExpenseClasses == '##[0]'


  Scenario: Full hierarchy - fiscal year, ledger, group, fund, budget and expense class
    * def fiscalYearId = call uuid
    * def ledgerId = call uuid
    * def groupId = call uuid
    * def fundId = call uuid
    * def budgetId = call uuid
    * def expenseClassId = call uuid
    * def v = call createFiscalYear { id: '#(fiscalYearId)', code: 'FYHIERF2066', periodStart: '2066-01-01', periodEnd: '2066-12-31', series: 'FYHIERF' }
    * def v = call createLedger { id: '#(ledgerId)', fiscalYearId: '#(fiscalYearId)' }

    Given path 'finance/groups'
    And request { id: '#(groupId)', code: '#(groupId)', name: '#(groupId)', status: 'Active' }
    When method POST
    Then status 201

    * def v = call createExpenseClass { id: '#(expenseClassId)', code: '#(expenseClassId)', name: '#(expenseClassId)', externalAccountNumberExt: '01' }
    * def v = call createFund { id: '#(fundId)', ledgerId: '#(ledgerId)' }
    * def statusExpenseClasses = [{ expenseClassId: '#(expenseClassId)', status: 'Active' }]
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', fiscalYearId: '#(fiscalYearId)', allocated: 1000, statusExpenseClasses: '#(statusExpenseClasses)' }

    Given path 'finance/group-fund-fiscal-years'
    And request { groupId: '#(groupId)', fundId: '#(fundId)', fiscalYearId: '#(fiscalYearId)', budgetId: '#(budgetId)' }
    When method POST
    Then status 201

    Given path 'finance/fiscal-year-hierarchy'
    And param fiscalYearId = fiscalYearId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def h = response.fiscalYearHierarchies[0]
    And match h.fiscalYearId == fiscalYearId
    And match h.ledgerId == ledgerId
    And match h.funds == '##[0]'
    And match h.groups[0].groupId == groupId
    * def fund = h.groups[0].funds[0]
    And match fund.fundId == fundId
    And match fund.budget.budgetId == budgetId
    And match fund.budget.budgetExpenseClasses == '#[1]'
    And match fund.budget.budgetExpenseClasses[0].expenseClassId == expenseClassId
    And match fund.budget.budgetExpenseClasses[0].status == 'Active'


  Scenario: Filters by ledger, group, fund, budget and expense class status
    * def fiscalYearId = call uuid
    * def activeLedgerId = call uuid
    * def inactiveLedgerId = call uuid
    * def activeGroupId = call uuid
    * def inactiveGroupId = call uuid
    * def fundInActiveGroupId = call uuid
    * def fundInInactiveGroupId = call uuid
    * def ungroupedFundId = call uuid
    * def inactiveFundId = call uuid
    * def fundInInactiveLedgerId = call uuid
    * def activeBudgetId = call uuid
    * def inactiveBudgetId = call uuid
    * def plannedBudgetId = call uuid
    * def budgetInInactiveFundId = call uuid
    * def budgetInInactiveLedgerId = call uuid
    * def activeExpenseClassId = call uuid
    * def inactiveExpenseClassId = call uuid

    # Fiscal year and ledgers (one Active, one Inactive)
    * def v = call createFiscalYear { id: '#(fiscalYearId)', code: 'FYHIERG2067', periodStart: '2067-01-01', periodEnd: '2067-12-31', series: 'FYHIERG' }
    * def v = call createLedger { id: '#(activeLedgerId)', fiscalYearId: '#(fiscalYearId)' }

    # createLedger always creates Active ledgers, so the Inactive one is created inline
    Given path 'finance/ledgers'
    And request
    """
    {
      "id": "#(inactiveLedgerId)",
      "name": "#(inactiveLedgerId)",
      "code": "#(inactiveLedgerId)",
      "fiscalYearOneId": "#(fiscalYearId)",
      "ledgerStatus": "Inactive",
      "netTransfers": 0.0,
      "acqUnitIds": [],
      "restrictEncumbrance": true,
      "restrictExpenditures": true
    }
    """
    When method POST
    Then status 201

    # Groups (one Active, one Inactive)
    Given path 'finance/groups'
    And request { id: '#(activeGroupId)', code: '#(activeGroupId)', name: '#(activeGroupId)', status: 'Active' }
    When method POST
    Then status 201

    Given path 'finance/groups'
    And request { id: '#(inactiveGroupId)', code: '#(inactiveGroupId)', name: '#(inactiveGroupId)', status: 'Inactive' }
    When method POST
    Then status 201

    # Expense classes
    * def v = call createExpenseClass { id: '#(activeExpenseClassId)', code: '#(activeExpenseClassId)', name: '#(activeExpenseClassId)', externalAccountNumberExt: '01' }
    * def v = call createExpenseClass { id: '#(inactiveExpenseClassId)', code: '#(inactiveExpenseClassId)', name: '#(inactiveExpenseClassId)', externalAccountNumberExt: '02' }

    # Active ledger: funds
    * table funds
      | id                     | ledgerId         | fundStatus |
      | fundInActiveGroupId    | activeLedgerId   | 'Active'   |
      | fundInInactiveGroupId  | activeLedgerId   | 'Active'   |
      | ungroupedFundId        | activeLedgerId   | 'Active'   |
      | inactiveFundId         | activeLedgerId   | 'Inactive' |
      | fundInInactiveLedgerId | inactiveLedgerId | 'Active'   |
    * def v = call createFund funds

    # Budgets: Active (with one Active and one Inactive expense class), Inactive, Planned
    * def statusExpenseClasses = [{ expenseClassId: '#(activeExpenseClassId)', status: 'Active' }, { expenseClassId: '#(inactiveExpenseClassId)', status: 'Inactive' }]
    * def v = call createBudget { id: '#(activeBudgetId)', fundId: '#(fundInActiveGroupId)', fiscalYearId: '#(fiscalYearId)', allocated: 1000, budgetStatus: 'Active', statusExpenseClasses: '#(statusExpenseClasses)' }
    * def v = call createBudget { id: '#(inactiveBudgetId)', fundId: '#(fundInInactiveGroupId)', fiscalYearId: '#(fiscalYearId)', allocated: 1000, budgetStatus: 'Inactive' }
    * def v = call createBudget { id: '#(plannedBudgetId)', fundId: '#(ungroupedFundId)', fiscalYearId: '#(fiscalYearId)', allocated: 1000, budgetStatus: 'Planned' }
    * def v = call createBudget { id: '#(budgetInInactiveFundId)', fundId: '#(inactiveFundId)', fiscalYearId: '#(fiscalYearId)', allocated: 1000, budgetStatus: 'Active' }
    * def v = call createBudget { id: '#(budgetInInactiveLedgerId)', fundId: '#(fundInInactiveLedgerId)', fiscalYearId: '#(fiscalYearId)', allocated: 1000, budgetStatus: 'Active' }

    # Group-fund relations for this fiscal year
    Given path 'finance/group-fund-fiscal-years'
    And request { groupId: '#(activeGroupId)', fundId: '#(fundInActiveGroupId)', fiscalYearId: '#(fiscalYearId)', budgetId: '#(activeBudgetId)' }
    When method POST
    Then status 201

    Given path 'finance/group-fund-fiscal-years'
    And request { groupId: '#(inactiveGroupId)', fundId: '#(fundInInactiveGroupId)', fiscalYearId: '#(fiscalYearId)', budgetId: '#(inactiveBudgetId)' }
    When method POST
    Then status 201

    # 1. Without filters - everything is returned
    Given path 'finance/fiscal-year-hierarchy'
    And param fiscalYearId = fiscalYearId
    When method GET
    Then status 200
    * def ledgerIds = karate.map(response.fiscalYearHierarchies, function(h) { return h.ledgerId })
    And match ledgerIds contains only [ '#(activeLedgerId)', '#(inactiveLedgerId)' ]
    * def fundIds = karate.map(collectFunds(response.fiscalYearHierarchies), function(f) { return f.fundId })
    And match fundIds contains only [ '#(fundInActiveGroupId)', '#(fundInInactiveGroupId)', '#(ungroupedFundId)', '#(inactiveFundId)', '#(fundInInactiveLedgerId)' ]

    # 2. ledgerStatus=Active - inactive ledger is excluded
    Given path 'finance/fiscal-year-hierarchy'
    And param fiscalYearId = fiscalYearId
    And param ledgerStatus = 'Active'
    When method GET
    Then status 200
    * def ledgerIds = karate.map(response.fiscalYearHierarchies, function(h) { return h.ledgerId })
    And match ledgerIds contains only [ '#(activeLedgerId)' ]

    # 3. groupStatus=Active - only active group is returned and ungrouped funds are excluded
    Given path 'finance/fiscal-year-hierarchy'
    And param fiscalYearId = fiscalYearId
    And param groupStatus = 'Active'
    When method GET
    Then status 200
    * def activeLedger = karate.filter(response.fiscalYearHierarchies, function(h) { return h.ledgerId == activeLedgerId })[0]
    * def groupIds = karate.map(activeLedger.groups, function(g) { return g.groupId })
    And match groupIds contains only [ '#(activeGroupId)' ]
    And match activeLedger.funds == '##[0]'

    # 4. fundStatus=Active - inactive fund is excluded
    Given path 'finance/fiscal-year-hierarchy'
    And param fiscalYearId = fiscalYearId
    And param fundStatus = 'Active'
    When method GET
    Then status 200
    * def fundIds = karate.map(collectFunds(response.fiscalYearHierarchies), function(f) { return f.fundId })
    And match fundIds !contains inactiveFundId
    And match fundIds contains fundInActiveGroupId

    # 5. budgetStatus=Active - only active budgets are returned
    Given path 'finance/fiscal-year-hierarchy'
    And param fiscalYearId = fiscalYearId
    And param budgetStatus = 'Active'
    When method GET
    Then status 200
    * def budgets = karate.filter(karate.map(collectFunds(response.fiscalYearHierarchies), function(f) { return f.budget }), function(b) { return b != null })
    * def budgetIds = karate.map(budgets, function(b) { return b.budgetId })
    And match budgetIds contains only [ '#(activeBudgetId)', '#(budgetInInactiveFundId)', '#(budgetInInactiveLedgerId)' ]
    And match each budgets contains { budgetStatus: 'Active' }

    # 6. expenseClassStatus=Active - inactive budget expense class is excluded
    Given path 'finance/fiscal-year-hierarchy'
    And param fiscalYearId = fiscalYearId
    And param expenseClassStatus = 'Active'
    When method GET
    Then status 200
    * def budgets = karate.filter(karate.map(collectFunds(response.fiscalYearHierarchies), function(f) { return f.budget }), function(b) { return b != null })
    * def expenseClassIds = karate.map(collectExpenseClasses(budgets), function(e) { return e.expenseClassId })
    And match expenseClassIds contains activeExpenseClassId
    And match expenseClassIds !contains inactiveExpenseClassId


  Scenario: Missing fiscalYearId returns 400
    Given path 'finance/fiscal-year-hierarchy'
    When method GET
    Then status 400
