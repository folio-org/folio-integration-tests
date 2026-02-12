# For MODORDERS-1191, https://foliotest.testrail.io/index.php?/cases/view/605930
Feature: Total Expended Amount Calculation With Different Fund Distributions

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

  @C605930
  @Positive
  Scenario: Total Expended Amount Calculation With Different Fund Distributions
    # Generate unique identifiers for this test scenario
    * def fundAId = call uuid
    * def budgetAId = call uuid
    * def fundBId = call uuid
    * def budgetBId = call uuid
    * def fundCId = call uuid
    * def budgetCId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoice1Id = call uuid
    * def invoice1LineId = call uuid
    * def invoice2Id = call uuid
    * def invoice2LineId = call uuid

    # 1. Create Three Different Funds With Current Budgets
    * print '1. Create Three Different Funds With Current Budgets'
    * def v = call createFund { id: "#(fundAId)", name: "Fund A" }
    * def v = call createBudget { id: "#(budgetAId)", fundId: "#(fundAId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 100, status: "Active" }
    * def v = call createFund { id: "#(fundBId)", name: "Fund B" }
    * def v = call createBudget { id: "#(budgetBId)", fundId: "#(fundBId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 100, status: "Active" }
    * def v = call createFund { id: "#(fundCId)", name: "Fund C" }
    * def v = call createBudget { id: "#(budgetCId)", fundId: "#(fundCId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 100, status: "Active" }

    # 2. Create Order In Open Status With One PO Line, Fund Distribution Specified With Fund A
    * print '2. Create Order In Open Status With One PO Line, Fund Distribution Specified With Fund A'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "One-Time" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundAId)", listUnitPrice: 1.00, titleOrPackage: "Test Order Line" }
    * def v = call openOrder { orderId: "#(orderId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 3. Create Invoice 1 With Fund Distribution Different From POL (Fund B)
    * print '3. Create Invoice 1 With Fund Distribution Different From POL (Fund B)'
    * def v = call createInvoice { id: "#(invoice1Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice1LineId)", invoiceId: "#(invoice1Id)", poLineId: "#(orderLineId)", fundId: "#(fundBId)", total: 1.00, releaseEncumbrance: false }

    # 4. Create Invoice 2 With Fund Distribution Different From POL And Invoice 1 (Fund C)
    * print '4. Create Invoice 2 With Fund Distribution Different From POL And Invoice 1 (Fund C)'
    * def v = call createInvoice { id: "#(invoice2Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice2LineId)", invoiceId: "#(invoice2Id)", poLineId: "#(orderLineId)", fundId: "#(fundCId)", total: 1.00, releaseEncumbrance: false }

    # 5. Approve And Pay Both Invoices
    * print '5. Approve And Pay Both Invoices'
    * def v = call approveInvoice { invoiceId: "#(invoice1Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice1Id)" }
    * def v = call approveInvoice { invoiceId: "#(invoice2Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice2Id)" }

    # 6. Navigate To Order Details Pane And Verify Total Expended
    * print '6. Navigate To Order Details Pane And Verify Total Expended'
    * def validateOrderTotals =
    """
    function(response) {
      return response.totalEstimatedPrice == 1.00 &&
             response.totalEncumbered == 0.00 &&
             response.totalExpended == 2.00 &&
             response.totalCredited == 0.00;
    }
    """
    Given path 'orders/composite-orders', orderId
    And retry until validateOrderTotals(response)
    When method GET
    Then status 200
