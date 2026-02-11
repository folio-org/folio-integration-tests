# For MODORDERS-1204, https://foliotest.testrail.io/index.php?/cases/view/610241
Feature: Total Expended Amount Calculation With No Encumbrances And No Related Paid Invoices

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

  @C610241
  @Positive
  Scenario: Total Expended Amount Calculation With No Encumbrances And No Related Paid Invoices
    # Generate unique identifiers for this test scenario
    * def fundAId = call uuid
    * def budgetAId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoice1Id = call uuid
    * def invoice1LineId = call uuid
    * def invoice2Id = call uuid
    * def invoice2LineId = call uuid
    * def invoice3Id = call uuid
    * def invoice3LineId = call uuid
    * def invoice4Id = call uuid
    * def invoice4LineId = call uuid

    # 1. Create Fund A With Budget Having Money Allocation
    * print '1. Create Fund A With Budget Having Money Allocation'
    * def v = call createFund { id: "#(fundAId)", name: "Fund A" }
    * def v = call createBudget { id: "#(budgetAId)", fundId: "#(fundAId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 100, status: "Active" }

    # 2. Create Order In Open Status With One PO Line Without Fund Distribution
    * print '2. Create Order In Open Status With One PO Line Without Fund Distribution'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "One-Time" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", listUnitPrice: 5.00, titleOrPackage: "Test Order Line", fundDistribution: [] }
    * def v = call openOrder { orderId: "#(orderId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 3. Create Invoice 1, Remains In Open Status
    * print '3. Create Invoice 1, Remains In Open Status'
    * def v = call createInvoice { id: "#(invoice1Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice1LineId)", invoiceId: "#(invoice1Id)", poLineId: "#(orderLineId)", fundId: "#(fundAId)", total: 1.00, releaseEncumbrance: false }

    # 4. Create Reviewed Invoice 2, Remains In Reviewed Status
    * print '4. Create Reviewed Invoice 2, Remains In Reviewed Status'
    * def v = call createInvoice { id: "#(invoice2Id)", fiscalYearId: "#(globalFiscalYearId)" }
    Given path 'invoice/invoices', invoice2Id
    When method GET
    Then status 200
    * def invoice2 = response
    * set invoice2.status = "Reviewed"
    Given path 'invoice/invoices', invoice2Id
    And request invoice2
    When method PUT
    Then status 204
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice2LineId)", invoiceId: "#(invoice2Id)", poLineId: "#(orderLineId)", fundId: "#(fundAId)", total: 1.00, releaseEncumbrance: false }

    # 5. Create Invoice 3, Approve It
    * print '5. Create Invoice 3, Approve It'
    * def v = call createInvoice { id: "#(invoice3Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice3LineId)", invoiceId: "#(invoice3Id)", poLineId: "#(orderLineId)", fundId: "#(fundAId)", total: 1.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice3Id)" }

    # 6. Create Invoice 4, Approve And Then Cancel It
    * print '6. Create Invoice 4, Approve And Then Cancel It'
    * def v = call createInvoice { id: "#(invoice4Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice4LineId)", invoiceId: "#(invoice4Id)", poLineId: "#(orderLineId)", fundId: "#(fundAId)", total: 1.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice4Id)" }
    * def v = call cancelInvoice { invoiceId: "#(invoice4Id)" }

    # 7. Navigate To Order Details Pane And Verify Total Expended Is 0.00
    * print '7. Navigate To Order Details Pane And Verify Total Expended Is 0.00'
    * def validateOrderTotals =
    """
    function(response) {
      return response.totalEncumbered == 0.00 &&
             response.totalExpended == 0.00 &&
             response.totalCredited == 0.00 &&
             response.totalItems == 1;
    }
    """
    Given path 'orders/composite-orders', orderId
    And retry until validateOrderTotals(response)
    When method GET
    Then status 200


