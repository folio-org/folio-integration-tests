# For MODFISTO-484, https://foliotest.testrail.io/index.php?/cases/view/496145
Feature: Correct Financial Summary Values When Approved And Paid Amounts Exceed Available Amount

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 10, interval: 10000 }

    * callonce variables

  @C496145
  @Positive
  Scenario: Correct Financial Summary Values When Approved And Paid Amounts Exceed Available Amount
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def budgetId = call uuid
    * def invoice1Id = call uuid
    * def invoice1LineId = call uuid
    * def invoice2Id = call uuid
    * def invoice2LineId = call uuid

    # 1. Create Ledger With Restrictions Disabled, Fund And Budget Allocated At $1500
    * print '1. Create Ledger With Restrictions Disabled, Fund And Budget Allocated At $1500'
    * def v = call createLedger { id: "#(ledgerId)", restrictEncumbrance: false, restrictExpenditures: false }
    * def v = call createFund { id: "#(fundId)", ledgerId: "#(ledgerId)" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", allocated: 1500, allowableEncumbrance: 100.0, allowableExpenditure: 100.0 }

    # 2. Create And Approve Invoice #1 For $1000 (Not Based On Order, Release Encumbrance False)
    * print '2. Create And Approve Invoice #1 For $1000 (Not Based On Order)'
    * def v = call createInvoice { id: "#(invoice1Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice1LineId)", invoiceId: "#(invoice1Id)", fundId: "#(fundId)", total: 1000.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice1Id)" }

    # 3. Create, Approve And Pay Invoice #2 For $1000 (Not Based On Order)
    * print '3. Create, Approve And Pay Invoice #2 For $1000 (Not Based On Order)'
    * def v = call createInvoice { id: "#(invoice2Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice2LineId)", invoiceId: "#(invoice2Id)", fundId: "#(fundId)", total: 1000.00, releaseEncumbrance: true }
    * def v = call approveInvoice { invoiceId: "#(invoice2Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice2Id)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 4. Verify Fund Summary - Allocated, Net Transfers, Unavailable, Available
    * print '4. Verify Fund Summary - Allocated, Net Transfers, Unavailable, Available'
    * def validateFundBudgetRow =
    """
    function(response) {
      return response.allocated == 1500.00 &&
             response.netTransfers == 0.00 &&
             response.unavailable == 2000.00 &&
             response.available == -500.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateFundBudgetRow(response)
    When method GET
    Then status 200

    # 5. Verify Budget Summary - Funding Information And Financial Activity
    * print '5. Verify Budget Summary - Funding Information And Financial Activity'
    * def validateBudgetSummary =
    """
    function(response) {
      return response.initialAllocation == 1500.00 &&
             response.allocationTo == 0.00 &&
             response.allocationFrom == 0.00 &&
             response.allocated == 1500.00 &&
             response.netTransfers == 0.00 &&
             response.totalFunding == 1500.00 &&
             response.cashBalance == 500.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 1000.00 &&
             response.expenditures == 1000.00 &&
             response.credits == 0.00 &&
             response.unavailable == 2000.00 &&
             response.overEncumbrance == 0.00 &&
             response.overExpended == 500.00 &&
             response.available == -500.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetSummary(response)
    When method GET
    Then status 200
