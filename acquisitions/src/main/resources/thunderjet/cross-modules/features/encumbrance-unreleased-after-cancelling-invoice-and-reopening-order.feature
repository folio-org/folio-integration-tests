# For MODINVOICE-616, https://foliotest.testrail.io//index.php?/cases/view/877072
Feature: Encumbrance Unreleased After Cancelling Invoice And Reopening Order

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

  @Positive
  Scenario: Encumbrance Unreleased After Cancelling Invoice And Reopening Order
    # Generate unique identifiers for this test scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoice1Id = call uuid
    * def invoice1LineId = call uuid
    * def invoice2Id = call uuid
    * def invoice2LineId = call uuid
    * def invoice3Id = call uuid
    * def invoice3LineId = call uuid

    # 1. Create Fund And Budget
    * print '1. Create Fund And Budget'
    * def v = call createFund { id: "#(fundId)", name: "Test Fund" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 2. Create One-time Order With Order Line
    * print '2. Create One-time Order With Order Line'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "One-Time" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 10.00, titleOrPackage: "Test One-time Order" }

    # 3. Open The Order
    * print '3. Open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 4. Create Invoice #1 With $5 Amount And Pay It
    * print '4. Create Invoice #1 With $5 Amount And Pay It'
    * def v = call createInvoice { id: "#(invoice1Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice1LineId)", invoiceId: "#(invoice1Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 5.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice1Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice1Id)" }

    # 5. Create Credit Invoice #2 With -$1 Amount And Pay It
    * print '5. Create Credit Invoice #2 With -$1 Amount And Pay It'
    * def v = call createInvoice { id: "#(invoice2Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice2LineId)", invoiceId: "#(invoice2Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: -1.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice2Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice2Id)" }

    # 6. Create Invoice #3 With $3 Amount And Pay It
    * print '6. Create Invoice #3 With $3 Amount And Pay It'
    * def v = call createInvoice { id: "#(invoice3Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice3LineId)", invoiceId: "#(invoice3Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 3.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice3Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice3Id)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 7. Verify Order State After All Invoices Are Paid
    * print '7. Verify Order State After All Invoices Are Paid'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 3.00 && response.totalExpended == 8.00 && response.totalCredited == 1.00
    When method GET
    Then status 200

    # 8. Cancel Invoice #1
    * print '8. Cancel Invoice #1'
    * def v = call cancelInvoice { invoiceId: "#(invoice1Id)" }

    # 9. Verify Encumbrance Details After Canceling Invoice #1
    * print '9. Verify Encumbrance Details After Canceling Invoice #1'
    * def validateEncumbranceAfterCancel =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 8.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 3.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterCancel(response)
    When method GET
    Then status 200

    # 10. Verify Budget State After Canceling Invoice #1
    * print '10. Verify Budget State After Canceling Invoice #1'
    * def validateBudgetAfterCancel =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 8.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 3.00 &&
             response.credited == 1.00 &&
             response.available == 990.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterCancel(response)
    When method GET
    Then status 200

    # 11. Cancel The Order
    * print '11. Cancel The Order'
    * def v = call cancelOrder { orderId: "#(orderId)" }

    # 12. Verify Order State After Canceling
    * print '12. Verify Order State After Canceling'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Closed' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 0.00 && response.totalExpended == 3.00 && response.totalCredited == 1.00
    When method GET
    Then status 200

    # 13. Verify Encumbrance Details After Canceling Order
    * print '13. Verify Encumbrance Details After Canceling Order'
    * def validateEncumbranceAfterOrderCancel =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 0.00 &&
             transaction.encumbrance.status == 'Released' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 3.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterOrderCancel(response)
    When method GET
    Then status 200

    # 14. Verify Budget State After Canceling Order
    * print '14. Verify Budget State After Canceling Order'
    * def validateBudgetAfterOrderCancel =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 3.00 &&
             response.credited == 1.00 &&
             response.available == 998.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterOrderCancel(response)
    When method GET
    Then status 200

    # 15. Reopen The Order
    * print '15. Reopen The Order'
    * def v = call reopenOrder { orderId: "#(orderId)" }

    # 16. Verify Order State After Reopening
    * print '16. Verify Order State After Reopening'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 8.00 && response.totalExpended == 3.00 && response.totalCredited == 1.00
    When method GET
    Then status 200

    # 17. Verify Encumbrance Details After Reopening Order
    * print '17. Verify Encumbrance Details After Reopening Order'
    * def validateEncumbranceAfterReopen =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 8.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 3.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterReopen(response)
    When method GET
    Then status 200

    # 18. Verify Final Budget State After Reopening Order
    * print '18. Verify Final Budget State After Reopening Order'
    * def validateBudgetAfterReopen =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 8.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 3.00 &&
             response.credited == 1.00 &&
             response.available == 990.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterReopen(response)
    When method GET
    Then status 200
