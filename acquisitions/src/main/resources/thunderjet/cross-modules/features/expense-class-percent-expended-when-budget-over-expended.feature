# For FAT-21153, https://foliotest.testrail.io/index.php?/cases/view/496115
Feature: Expense Class Percent Of Total Expended Calculated Correctly When Budget Over Expended

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 5, interval: 5000 }
    * configure readTimeout = 120000
    * configure connectTimeout = 120000

    * callonce variables

  @C496115
  @Positive
  Scenario: Expense Class Percent Of Total Expended Calculated Correctly When Budget Over Expended
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def budgetId = call uuid
    * def expenseClassId = call uuid
    * def groupId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create Ledger With Encumbrance Restriction Disabled And Expenditure Restriction Enabled
    * print '1. Create Ledger With Encumbrance Restriction Disabled And Expenditure Restriction Enabled'
    * def v = call createLedger { id: '#(ledgerId)', restrictEncumbrance: false, restrictExpenditures: true }

    # 2. Create Fund And Budget Allocated At $100 With 110% Allowable Encumbrance And Expenditure
    * print '2. Create Fund And Budget Allocated At $100 With 110% Allowable Encumbrance And Expenditure'
    * def v = call createFund { id: '#(fundId)', ledgerId: '#(ledgerId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 100, allowableEncumbrance: 110.0, allowableExpenditure: 110.0 }

    # 3. Create Expense Class And Assign It To Budget
    * print '3. Create Expense Class And Assign It To Budget'
    * def v = call createExpenseClass { id: '#(expenseClassId)', code: '#(expenseClassId)', name: '#(expenseClassId)' }
    Given path 'finance/budgets', budgetId
    When method GET
    Then status 200
    * def budget = response
    * set budget.statusExpenseClasses = [{ 'expenseClassId': '#(expenseClassId)', 'status': 'Active' }]
    Given path 'finance/budgets', budgetId
    And request budget
    When method PUT
    Then status 204

    # 4. Create Group And Add Fund To Group
    * print '4. Create Group And Add Fund To Group'
    Given path 'finance/groups'
    And request { 'id': '#(groupId)', 'status': 'Active', 'name': '#(groupId)', 'code': '#(groupId)' }
    When method POST
    Then status 201
    Given path 'finance/funds', fundId
    When method GET
    Then status 200
    * def fund = response
    * set fund.groupIds = ['#(groupId)']
    Given path 'finance/funds', fundId
    And request fund
    When method PUT
    Then status 204

    # 5. Create And Open Order With Order Line For $101 With Fund And Expense Class
    * print '5. Create And Open Order With Order Line For $101 With Fund And Expense Class'
    * def v = call createOrder { id: '#(orderId)', vendor: '#(globalVendorId)', orderType: 'One-Time' }
    * def v = call createOrderLine { id: '#(orderLineId)', orderId: '#(orderId)', fundId: '#(fundId)', expenseClassId: '#(expenseClassId)', listUnitPrice: 101.00, titleOrPackage: 'Order For Over Expended Expense Class Test' }
    * def v = call openOrder { orderId: '#(orderId)' }

    # 6. Create Invoice Based On Order, Approve And Pay It
    * print '6. Create Invoice Based On Order, Approve And Pay It'
    * def v = call createInvoice { id: '#(invoiceId)', fiscalYearId: '#(globalFiscalYearId)' }
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(orderLineId)', fundId: '#(fundId)', expenseClassId: '#(expenseClassId)', total: 101.00, releaseEncumbrance: true }
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }
    * def v = call payInvoice { invoiceId: '#(invoiceId)' }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 7. Verify Fund Budget Summary - Allocated, Net Transfers, Unavailable, Available (TestRail Step 1)
    * print '7. Verify Fund Budget Summary - Allocated, Net Transfers, Unavailable, Available (TestRail Step 1)'
    * def validateBudgetSummary =
    """
    function(response) {
      return response.allocated == 100.00 &&
             response.netTransfers == 0.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 101.00 &&
             response.credits == 0.00 &&
             response.unavailable == 101.00 &&
             response.available == -1.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetSummary(response)
    When method GET
    Then status 200

    # 8. Verify Budget Expense Class Totals - Encumbered, Awaiting Payment, Expended, Percent Of Total Expended (TestRail Steps 1 And 2)
    * print '8. Verify Budget Expense Class Totals - Encumbered, Awaiting Payment, Expended, Percent Of Total Expended (TestRail Steps 1 And 2)'
    * def validateBudgetExpenseClassTotals =
    """
    function(response) {
      var totals = karate.jsonPath(response, "$.budgetExpenseClassTotals[*][?(@.id != 'UNASSIGNED')]");
      if (!totals || totals.length == 0) return false;
      return totals[0].encumbered == 0.00 &&
             totals[0].awaitingPayment == 0.00 &&
             totals[0].expended == 101.00 &&
             totals[0].percentageExpended == 100.0 &&
             totals[0].expenseClassStatus == 'Active';
    }
    """
    Given path 'finance/budgets', budgetId, 'expense-classes-totals'
    And retry until validateBudgetExpenseClassTotals(response)
    When method GET
    Then status 200

    # 9. Verify Group Expense Class Totals - Encumbered, Awaiting Payment, Expended, Percent Of Total Expended (TestRail Step 3)
    * print '9. Verify Group Expense Class Totals - Encumbered, Awaiting Payment, Expended, Percent Of Total Expended (TestRail Step 3)'
    * def validateGroupExpenseClassTotals =
    """
    function(response) {
      var totals = karate.jsonPath(response, "$.groupExpenseClassTotals[*][?(@.id != 'UNASSIGNED')]");
      if (!totals || totals.length == 0) return false;
      return totals[0].encumbered == 0.00 &&
             totals[0].awaitingPayment == 0.00 &&
             totals[0].expended == 101.00 &&
             totals[0].percentageExpended == 100.0;
    }
    """
    Given path 'finance/groups', groupId, 'expense-classes-totals'
    And param fiscalYearId = globalFiscalYearId
    And retry until validateGroupExpenseClassTotals(response)
    When method GET
    Then status 200
