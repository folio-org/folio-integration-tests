# For MODORDERS-1449, https://foliotest.testrail.io/index.php?/cases/view/1348694
Feature: Encumbrance Is Released After Un-opening The Order With Related Paid And Approved Invoices Release True

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

  @C1348694
  @Positive
  Scenario: Encumbrance Is Released After Un-opening The Order With Related Paid And Approved Invoices Release True
    # Generate unique identifiers for this test scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoice1Id = call uuid
    * def invoice1LineId = call uuid
    * def invoice2Id = call uuid
    * def invoice2LineId = call uuid

    # 1. Create Fund A And Budget With $1000 Allocation
    * def v = call createFund { id: "#(fundId)", name: "Fund A" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 2. Create Ongoing Order With Order Line Using Fund A And $10 Total Cost
    * def ongoingConfig = { "interval": 123, "isSubscription": false }
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "Ongoing", ongoing: "#(ongoingConfig)" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 10.00, titleOrPackage: "Test Ongoing Order" }

    # 3. Open The Order And Verify $10 Encumbrance
    * def v = call openOrder { orderId: "#(orderId)" }
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 10.00 && response.totalExpended == 0.00
    When method GET
    Then status 200

    # 4. Create Invoice #1 Based On The Order With Fund A, $4.00, Release Encumbrance True
    * def v = call createInvoice { id: "#(invoice1Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice1LineId)", invoiceId: "#(invoice1Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 4.00, releaseEncumbrance: true }

    # 5. Approve And Pay Invoice #1
    * def v = call approveInvoice { invoiceId: "#(invoice1Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice1Id)" }

    # 6. Create Invoice #2 Based On The Order With Fund A, $3.00, Release Encumbrance True
    * def v = call createInvoice { id: "#(invoice2Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice2LineId)", invoiceId: "#(invoice2Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 3.00, releaseEncumbrance: true }

    # 7. Approve Invoice #2
    * def v = call approveInvoice { invoiceId: "#(invoice2Id)" }

    # 8. Un-open The Order
    * def v = call unopenOrder { orderId: "#(orderId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 9. Verify Un-opened Order Details - Pending, Total Estimated Price $10.00, Total Expended $4.00
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Pending' && response.totalEstimatedPrice == 10.00 && response.totalExpended == 4.00 && response.totalCredited == 0.00
    When method GET
    Then status 200

    # 10. Re-open The Order
    * def v = call openOrder { orderId: "#(orderId)" }

    # 11. Verify Re-opened Order Totals - Encumbered $0.00, Expended $4.00
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 0.00 && response.totalExpended == 4.00 && response.totalCredited == 0.00
    When method GET
    Then status 200

    # 12. Verify Encumbrance Transaction - Amount $0.00, Initial $10.00, Awaiting Payment $3.00, Expended $4.00, Status Released
    * def validateReleasedEncumbrance =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 0.00 &&
             transaction.fromFundId == fundId &&
             transaction.encumbrance.status == 'Released' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.amountAwaitingPayment == 3.00 &&
             transaction.encumbrance.amountExpended == 4.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateReleasedEncumbrance(response)
    When method GET
    Then status 200

    # 13. Verify Budget State - Encumbered $0.00, Awaiting Payment $3.00, Expenditures $4.00, Available $993.00
    * def validateBudgetState =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 3.00 &&
             response.expenditures == 4.00 &&
             response.credits == 0.00 &&
             response.unavailable == 7.00 &&
             response.available == 993.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetState(response)
    When method GET
    Then status 200

