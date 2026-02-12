# For MODORDERS-1191, https://foliotest.testrail.io/index.php?/cases/view/594417
Feature: Total Expended Amount Calculation With Fund Distribution And Encumbrance

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

  @C594417
  @Positive
  Scenario: Total Expended Amount Calculation With Fund Distribution And Encumbrance
    # Generate unique identifiers for this test scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoice1Id = call uuid
    * def invoice2Id = call uuid
    * def invoice3Id = call uuid
    * def invoice1LineId = call uuid
    * def invoice2LineId = call uuid
    * def invoice3LineId = call uuid

    # 1. Create Fund With Budget Having Money Allocation
    * print '1. Create Fund With Budget Having Money Allocation'
    * def v = call createFund { id: "#(fundId)", name: "Test Fund" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 100, status: "Active" }

    # 2. Create Order In Open Status With One PO Line, Fund Distribution Specified
    * print '2. Create Order In Open Status With One PO Line, Fund Distribution Specified'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "One-Time" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 1.00, titleOrPackage: "Test Order Line" }
    * def v = call openOrder { orderId: "#(orderId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 3. Create Invoice 1
    * print '3. Create Invoice 1'
    * def v = call createInvoice { id: "#(invoice1Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice1LineId)", invoiceId: "#(invoice1Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 1.00, releaseEncumbrance: true }

    # 4. Create Invoice 2
    * print '4. Create Invoice 2'
    * def v = call createInvoice { id: "#(invoice2Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice2LineId)", invoiceId: "#(invoice2Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 1.00, releaseEncumbrance: true }

    # 5. Create Credit Invoice 3 With Negative Amount
    * print '5. Create Credit Invoice 3 With Negative Amount'
    * def v = call createInvoice { id: "#(invoice3Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice3LineId)", invoiceId: "#(invoice3Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: -1.00, releaseEncumbrance: true }

    # 6. Approve And Pay All Three Invoices
    * print '6. Approve And Pay All Three Invoices'
    * def v = call approveInvoice { invoiceId: "#(invoice1Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice1Id)" }
    * def v = call approveInvoice { invoiceId: "#(invoice2Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice2Id)" }
    * def v = call approveInvoice { invoiceId: "#(invoice3Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice3Id)" }

    # 7. Navigate To Order Details Pane And Verify Totals
    * print '7. Navigate To Order Details Pane And Verify Totals'
    * def validateOrderTotals =
    """
    function(response) {
      return response.totalEstimatedPrice == 1.00 &&
             response.totalEncumbered == 0.00 &&
             response.totalExpended == 2.00 &&
             response.totalCredited == 1.00;
    }
    """
    Given path 'orders/composite-orders', orderId
    And retry until validateOrderTotals(response)
    When method GET
    Then status 200
