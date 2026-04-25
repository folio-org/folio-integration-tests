# For MODFISTO-484, https://foliotest.testrail.io/index.php?/cases/view/496149
Feature: Budget Summary When Encumbered Approved And Paid Exceed Available Amount

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 10, interval: 10000 }

    * callonce variables

  @C496149
  @Positive
  Scenario: Budget Summary When Encumbered Approved And Paid Exceed Available Amount
    * def ledgerId = call uuid
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoice1Id = call uuid
    * def invoice1LineId = call uuid
    * def invoice2Id = call uuid
    * def invoice2LineId = call uuid

    # 1. Create Ledger With Restrictions Disabled, Fund And Budget Allocated At $1000
    * print '1. Create Ledger With Restrictions Disabled, Fund And Budget Allocated At $1000'
    * def v = call createLedger { id: "#(ledgerId)", restrictEncumbrance: false, restrictExpenditures: false }
    * def v = call createFund { id: "#(fundId)", ledgerId: "#(ledgerId)" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", allocated: 1000, allowableEncumbrance: 100.0, allowableExpenditure: 100.0 }

    # 2. Create And Approve Invoice #1 For $300 (Not Based On Order)
    * print '2. Create And Approve Invoice #1 For $300 (Not Based On Order)'
    * def v = call createInvoice { id: "#(invoice1Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice1LineId)", invoiceId: "#(invoice1Id)", fundId: "#(fundId)", total: 300.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice1Id)" }

    # 3. Create, Approve And Pay Invoice #2 For $200 (Not Based On Order)
    * print '3. Create, Approve And Pay Invoice #2 For $200 (Not Based On Order)'
    * def v = call createInvoice { id: "#(invoice2Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice2LineId)", invoiceId: "#(invoice2Id)", fundId: "#(fundId)", total: 200.00, releaseEncumbrance: true }
    * def v = call approveInvoice { invoiceId: "#(invoice2Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice2Id)" }

    # 4. Create And Open Order With PO Line For $1000 Against The Fund
    * print '4. Create And Open Order With PO Line For $1000 Against The Fund'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 1000.00, titleOrPackage: "Budget Summary Test" }
    * def v = call openOrder { orderId: "#(orderId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 5. Verify Fund Budget Row - Allocated, Net Transfers, Unavailable, Available
    * print '5. Verify Fund Budget Row - Allocated, Net Transfers, Unavailable, Available'
    * def validateFundBudgetRow =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.netTransfers == 0.00 &&
             response.unavailable == 1500.00 &&
             response.available == -500.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateFundBudgetRow(response)
    When method GET
    Then status 200

    # 6. Verify Budget Summary - Funding Information And Financial Activity
    * print '6. Verify Budget Summary - Funding Information And Financial Activity'
    * def validateBudgetSummary =
    """
    function(response) {
      return response.initialAllocation == 1000.00 &&
             response.allocationTo == 0.00 &&
             response.allocationFrom == 0.00 &&
             response.allocated == 1000.00 &&
             response.netTransfers == 0.00 &&
             response.totalFunding == 1000.00 &&
             response.cashBalance == 800.00 &&
             response.encumbered == 1000.00 &&
             response.awaitingPayment == 300.00 &&
             response.expenditures == 200.00 &&
             response.credits == 0.00 &&
             response.unavailable == 1500.00 &&
             response.overEncumbrance == 500.00 &&
             response.overExpended == 0.00 &&
             response.available == -500.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetSummary(response)
    When method GET
    Then status 200
