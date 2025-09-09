# For MODINVOICE-608, https://foliotest.testrail.io/index.php?/cases/view/844257
Feature: Encumbrance Calculated Correctly For Unopened Ongoing Order With Approved Invoice

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser
    * configure retry = { count: 15, interval: 15000 }

    * callonce variables

  @Positive
  Scenario: Encumbrance Calculated Correctly For Unopened Ongoing Order With Approved Invoice And After Canceling Approved Invoice
    # Generate unique identifiers for this test scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create Fund And Budget
    * def v = call createFund { id: "#(fundId)", name: "Encumbrance Test Fund" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", allocated: 1000, status: "Active" }

    # 2. Create Ongoing Order With Fund Distribution
    * def ongoingConfig = { "interval": 123, "isSubscription": false }
    * def v = call createOrder { id: '#(orderId)', vendor: '#(globalVendorId)', orderType: 'Ongoing', ongoing: '#(ongoingConfig)' }

    # 3. Create Order Line With Fund Distribution
    * def v = call createOrderLine { id: '#(orderLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 5.00, titleOrPackage: 'Test Ongoing Order' }

    # 4. Open Order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Verify Order Is Open And Initial Encumbrance
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open'
    When method GET
    Then status 200
    And match response.totalEstimatedPrice == 5.00
    And match response.totalEncumbered == 5.00

    # 6. Create Invoice Based On The Order
    * def v = call createInvoice { id: '#(invoiceId)', fiscalYearId: '#(globalFiscalYearId)' }

    # 7. Create Invoice Line With Release Encumbrance
    * def v = call createInvoiceLine { invoiceLineId: '#(invoiceLineId)', invoiceId: '#(invoiceId)', poLineId: '#(orderLineId)', fundId: '#(fundId)', total: 50.00, releaseEncumbrance: true }

    # 8. Approve The Invoice
    * def v = call approveInvoice { invoiceId: '#(invoiceId)' }

    # 9. Verify Invoice Is Approved
    Given path 'invoice/invoices', invoiceId
    And retry until response.status == 'Approved'
    When method GET
    Then status 200

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 10. Verify Order State After Second Invoice Operations - $0 Encumbered, 0 Expended
    Given path 'orders/composite-orders', orderId
    And retry until response.totalEncumbered == 0.00 && response.totalExpended == 0.00
    When method GET
    Then status 200

    # 11. Unopen The Order
    * def v = call unopenOrder { orderId: '#(orderId)' }

    # 12. Verify Order Status And Encumbrance After Unopen
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Pending'
    When method GET
    Then status 200
    And match response.totalEncumbered == 0.00

    # 13. Verify Encumbrance Details After Unopen
    * def validateEncumbranceAfterUnopen =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 0.00 &&
             transaction.encumbrance.status == 'Pending' &&
             transaction.encumbrance.initialAmountEncumbered == 0.00 &&
             transaction.encumbrance.amountAwaitingPayment == 50.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterUnopen(response)
    When method GET
    Then status 200

    # 14. Reopen The Order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 15. Verify Order Status And Encumbrance After Reopen
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open'
    When method GET
    Then status 200
    And match response.totalEncumbered == 0.00

    # 16. Verify Encumbrance Details After Reopen
    * def validateEncumbranceAfterReopen =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 0.00 &&
             transaction.encumbrance.status == 'Unreleased' && // Should be Released
             transaction.encumbrance.initialAmountEncumbered == 5.00 &&
             transaction.encumbrance.amountAwaitingPayment == 50.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterReopen(response)
    When method GET
    Then status 200

    # 17. Verify Budget State After Approved Invoice
    * def validateBudgetAfterApproval =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 50.00 &&
             response.expenditures == 0.00 &&
             response.available == 950.00 &&
             response.unavailable == 50.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterApproval(response)
    When method GET
    Then status 200

    # 18. Cancel The Invoice
    * def v = call cancelInvoice { invoiceId: '#(invoiceId)' }

    # 19. Verify Invoice Is Cancelled
    Given path 'invoice/invoices', invoiceId
    And retry until response.status == 'Cancelled'
    When method GET
    Then status 200

    # 20. Verify Encumbrance After Invoice Cancellation
    * def validateEncumbranceAfterCancel =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 5.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 5.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterCancel(response)
    When method GET
    Then status 200

    # 21. Verify Final Budget State After Invoice Cancellation
    * def validateFinalBudgetState =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 5.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 0.00 &&
             response.available == 995.00 &&
             response.unavailable == 5.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateFinalBudgetState(response)
    When method GET
    Then status 200
