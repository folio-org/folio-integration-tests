# For MODINVOICE-608, https://foliotest.testrail.io/index.php?/cases/view/829881
Feature: Encumbrance Remains 0 For Re Opened 0 Dollar Ongoing Order With Paid Invoice

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { "Content-Type": "application/json", "x-okapi-token": "#(okapitokenUser)", "Accept": "application/json", "x-okapi-tenant": "#(testTenant)" }
    * configure headers = headersUser
    * configure retry = { count: 15, interval: 15000 }

    * callonce variables

  @Positive
  Scenario: Encumbrance Remains 0 For Re Opened 0 Dollar Ongoing Order With Paid Invoice
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

    # 2. Create $0 Ongoing Order With Fund Distribution
    * def ongoingConfig = { "interval": 123, "isSubscription": false }
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "Ongoing", ongoing: "#(ongoingConfig)" }

    # 3. Create Order Line With $0 Cost
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 0, quantity: 1, titleOrPackage: "Test $0 Ongoing Order" }

    # 4. Open Order
    * def v = call openOrder { orderId: "#(orderId)" }

    # 5. Verify Order Is Open With $0 Encumbrance
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 0 && response.totalEncumbered == 0
    When method GET
    Then status 200

    # 6. Create Invoice With $50 Release Encumbrance = True
    * def v = call createInvoice { id: "#(invoiceId)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 50.00, releaseEncumbrance: true }

    # 7. Approve And Pay Invoice
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }
    * def v = call payInvoice { invoiceId: "#(invoiceId)" }

    # 8. Close Order
    * def v = call closeOrder { orderId: "#(orderId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 9. Verify Order Is Closed With Proper Financial State
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Closed' && response.totalEstimatedPrice == 0.00 && response.totalEncumbered == 0.00 && response.totalExpended == 50.00
    When method GET
    Then status 200

    # 10. Reopen The Closed Order
    * def v = call openOrder { orderId: "#(orderId)" }

    # 11. Verify Order Status After Reopen - $0 Encumbered, $50 Expended
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open'
    When method GET
    Then status 200
    And match response.totalEstimatedPrice == 0.00
    And match response.totalEncumbered == 0.00
    And match response.totalExpended == 50.00

    # 12. Verify Encumbrance Transaction Details After Reopen - Status Released, $50 Expended
    * def validateEncumbranceAfterReopen =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 0.00 &&
             transaction.encumbrance.status == 'Released' &&
             transaction.encumbrance.initialAmountEncumbered == 0.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 50.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterReopen(response)
    When method GET
    Then status 200
    * def encumbranceId = response.transactions[0].id

    # 13. Verify Budget State After Reopen - $950 Available, $50 Expended
    * def validateBudgetAfterReopen =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 50.00 &&
             response.available == 950.00 &&
             response.unavailable == 50.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterReopen(response)
    When method GET
    Then status 200

    # 14. Unrelease The Encumbrance
    Given path 'finance/unrelease-encumbrance', encumbranceId
    When method POST
    Then status 204

    # 15. Verify Encumbrance After Unrelease - Status Unreleased, Still $50 Expended
    * def validateEncumbranceUnreleased =
    """
    function(response) {
      return response.amount == 0.00 &&
             response.encumbrance.status == 'Unreleased' &&
             response.encumbrance.initialAmountEncumbered == 0.00 &&
             response.encumbrance.amountAwaitingPayment == 0.00 &&
             response.encumbrance.amountExpended == 50.00;
    }
    """
    Given path 'finance/transactions', encumbranceId
    And retry until validateEncumbranceUnreleased(response)
    When method GET
    Then status 200

    # 16. Verify Budget State Remains Same After Unrelease - Still $950 Available
    * def validateBudgetAfterUnrelease =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 50.00 &&
             response.available == 950.00 &&
             response.unavailable == 50.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterUnrelease(response)
    When method GET
    Then status 200

    # 17. Cancel The Paid Invoice
    * def v = call cancelInvoice { invoiceId: "#(invoiceId)" }

    # 18. Verify Invoice Is Cancelled
    Given path 'invoice/invoices', invoiceId
    And retry until response.status == 'Cancelled'
    When method GET
    Then status 200

    # 19. Verify Final Encumbrance State - $0 Amount, $0 Expended, Unreleased Status
    * def validateFinalEncumbrance =
    """
    function(response) {
      return response.amount == 0.00 &&
             response.encumbrance.status == 'Unreleased' &&
             response.encumbrance.initialAmountEncumbered == 0.00 &&
             response.encumbrance.amountAwaitingPayment == 0.00 &&
             response.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions', encumbranceId
    And retry until validateFinalEncumbrance(response)
    When method GET
    Then status 200

    # 20. Verify Final Budget State - Full $1000 Available After Invoice Cancellation
    * def validateFinalBudget =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 0.00 &&
             response.available == 1000.00 &&
             response.unavailable == 0.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateFinalBudget(response)
    When method GET
    Then status 200
