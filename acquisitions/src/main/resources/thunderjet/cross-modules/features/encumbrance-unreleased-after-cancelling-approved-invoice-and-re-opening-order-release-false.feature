# For MODINVOICE-617, https://foliotest.testrail.io/index.php?/cases/view/889716
Feature: Encumbrance Is Unreleased After Cancelling Related Approved Invoice And Re-Opening Order Release False

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
  Scenario: Encumbrance Is Unreleased After Cancelling Related Approved Invoice And Re-Opening Order Release False
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
    * def v = call createFund { id: "#(fundId)", name: "Encumbrance Test Fund" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 2. Create Ongoing Order With Order Line
    * print '2. Create Ongoing Order With Order Line'
    * def ongoingConfig = { "interval": 123, "isSubscription": false }
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "Ongoing", ongoing: "#(ongoingConfig)" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 10.00, titleOrPackage: "Test Ongoing Order", createInventory: "None" }

    # 3. Open The Order
    * print '3. Open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 4. Create Invoice 1 With Release Encumbrance False
    * print '4. Create Invoice 1 With Release Encumbrance False'
    * def v = call createInvoice { id: "#(invoice1Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice1LineId)", invoiceId: "#(invoice1Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 5.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice1Id)" }

    # 5. Create Credit Invoice 2 With Release Encumbrance False
    * print '5. Create Credit Invoice 2 With Release Encumbrance False'
    * def v = call createInvoice { id: "#(invoice2Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice2LineId)", invoiceId: "#(invoice2Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: -1.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice2Id)" }

    # 6. Create Invoice 3 With Release Encumbrance False
    * print '6. Create Invoice 3 With Release Encumbrance False'
    * def v = call createInvoice { id: "#(invoice3Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice3LineId)", invoiceId: "#(invoice3Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 3.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice3Id)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 7. Verify Order State After All Invoices Are Approved
    * print '7. Verify Order State After All Invoices Are Approved'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 3.00 && response.totalExpended == 0.00 && response.totalCredited == 0.00
    When method GET
    Then status 200

    # 8. Cancel Invoice 1
    * print '8. Cancel Invoice 1'
    * def v = call cancelInvoice { invoiceId: "#(invoice1Id)" }

    # 9. Verify Order State After Cancelling Invoice 1
    * print '9. Verify Order State After Cancelling Invoice 1'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 8.00 && response.totalExpended == 0.00 && response.totalCredited == 0.00
    When method GET
    Then status 200

    # 10. Verify Encumbrance State After Cancelling Invoice 1
    * print '10. Verify Encumbrance State After Cancelling Invoice 1'
    * def validateEncumbranceAfterCancel1 =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 8.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.amountAwaitingPayment == 2.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterCancel1(response)
    When method GET
    Then status 200

    # 11. Verify Budget State After Cancelling Invoice 1
    * print '11. Verify Budget State After Cancelling Invoice 1'
    * def validateBudgetAfterCancel1 =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 8.00 &&
             response.awaitingPayment == 2.00 &&
             response.expenditures == 0.00 &&
             response.credits == 0.00 &&
             response.available == 990.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterCancel1(response)
    When method GET
    Then status 200

    # 12. Close The Order
    * print '12. Close The Order'
    * def v = call closeOrder { orderId: "#(orderId)" }

    # 13. Verify Order State After Order Closure
    * print '13. Verify Order State After Order Closure'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Closed' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 0.00 && response.totalExpended == 0.00 && response.totalCredited == 0.00
    When method GET
    Then status 200

    # 14. Verify Encumbrance State After Order Closure
    * print '14. Verify Encumbrance State After Order Closure'
    * def validateEncumbranceAfterOrderClose =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 0.00 &&
             transaction.encumbrance.status == 'Released' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.amountAwaitingPayment == 2.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterOrderClose(response)
    When method GET
    Then status 200

    # 15. Verify Budget State After Order Closure
    * print '15. Verify Budget State After Order Closure'
    * def validateBudgetAfterOrderClose =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 2.00 &&
             response.expenditures == 0.00 &&
             response.credits == 0.00 &&
             response.available == 998.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterOrderClose(response)
    When method GET
    Then status 200

    # 16. Re-Open The Order
    * print '16. Re-Open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 17. Verify Order State After Re-Opening
    * print '17. Verify Order State After Re-Opening'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 8.00 && response.totalExpended == 0.00 && response.totalCredited == 0.00
    When method GET
    Then status 200

    # 18. Verify Encumbrance State After Re-Opening
    * print '18. Verify Encumbrance State After Re-Opening'
    * def validateEncumbranceAfterReopen =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 8.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.amountAwaitingPayment == 2.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterReopen(response)
    When method GET
    Then status 200

    # 19. Verify Budget State After Re-Opening
    * print '19. Verify Budget State After Re-Opening'
    * def validateBudgetAfterReopen =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 8.00 &&
             response.awaitingPayment == 2.00 &&
             response.expenditures == 0.00 &&
             response.credits == 0.00 &&
             response.available == 990.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterReopen(response)
    When method GET
    Then status 200

    # 20. Cancel Invoice 2
    * print '20. Cancel Invoice 2'
    * def v = call cancelInvoice { invoiceId: "#(invoice2Id)" }

    # 21. Verify Order State After Cancelling Invoice 2
    * print '21. Verify Order State After Cancelling Invoice 2'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 7.00 && response.totalExpended == 0.00 && response.totalCredited == 0.00
    When method GET
    Then status 200

    # 22. Verify Encumbrance State After Cancelling Invoice 2
    * print '22. Verify Encumbrance State After Cancelling Invoice 2'
    * def validateEncumbranceAfterCancel2 =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 7.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.amountAwaitingPayment == 3.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterCancel2(response)
    When method GET
    Then status 200

    # 23. Verify Budget State After Cancelling Invoice 2
    * print '23. Verify Budget State After Cancelling Invoice 2'
    * def validateBudgetAfterCancel2 =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 7.00 &&
             response.awaitingPayment == 3.00 &&
             response.expenditures == 0.00 &&
             response.credits == 0.00 &&
             response.available == 990.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterCancel2(response)
    When method GET
    Then status 200

    # 24. Cancel Invoice 3
    * print '24. Cancel Invoice 3'
    * def v = call cancelInvoice { invoiceId: "#(invoice3Id)" }

    # 25. Verify Order State After Cancelling Invoice 3
    * print '25. Verify Order State After Cancelling Invoice 3'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 10.00 && response.totalExpended == 0.00 && response.totalCredited == 0.00
    When method GET
    Then status 200

    # 26. Verify Encumbrance State After Cancelling Invoice 3
    * print '26. Verify Encumbrance State After Cancelling Invoice 3'
    * def validateEncumbranceAfterCancel3 =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 10.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterCancel3(response)
    When method GET
    Then status 200

    # 27. Verify Budget State After Cancelling Invoice 3
    * print '27. Verify Budget State After Cancelling Invoice 3'
    * def validateBudgetAfterCancel3 =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 10.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 0.00 &&
             response.credits == 0.00 &&
             response.available == 990.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterCancel3(response)
    When method GET
    Then status 200
