# For MODINVOICE-608, https://foliotest.testrail.io/index.php?/cases/view/825437
Feature: Encumbrance Remains 0 For 0 Dollar Ongoing Order After Canceling Paid Invoice

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
  Scenario: Encumbrance Remains 0 For 0 Dollar Ongoing Order After Canceling Paid Invoice
    # Generate unique identifiers for this test scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def firstInvoiceId = call uuid
    * def secondInvoiceId = call uuid
    * def firstInvoiceLineId = call uuid
    * def secondInvoiceLineId = call uuid

    # 1. Create Fund And Budget
    * def v = call createFund { id: "#(fundId)", name: "Encumbrance Test Fund" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 2. Create $0 Ongoing Order
    * def ongoingConfig = { "interval": 123, "isSubscription": false }
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "Ongoing", ongoing: "#(ongoingConfig)" }

    # 3. Create Order Line With $0 Cost
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 0, quantity: 1 }

    # 4. Open Order
    * def v = call openOrder { orderId: "#(orderId)" }

    # 5. Verify Initial Order State - $0 Encumbered, $0 Expended
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 0 && response.totalEncumbered == 0 && response.totalExpended == 0
    When method GET
    Then status 200

    # 6. Create First Invoice ($50) With Release Encumbrance = True
    * def v = call createInvoice { id: "#(firstInvoiceId)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(firstInvoiceLineId)", invoiceId: "#(firstInvoiceId)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 50, releaseEncumbrance: true }

    # 7. Approve And Pay First Invoice
    * def v = call approveInvoice { invoiceId: "#(firstInvoiceId)" }
    * def v = call payInvoice { invoiceId: "#(firstInvoiceId)" }

    # 8. Create Second Invoice ($200) With Release Encumbrance = True
    * def v = call createInvoice { id: "#(secondInvoiceId)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(secondInvoiceLineId)", invoiceId: "#(secondInvoiceId)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 200, releaseEncumbrance: true }

    # 9. Approve, Pay And Cancel Second Invoice
    * def v = call approveInvoice { invoiceId: "#(secondInvoiceId)" }
    * def v = call payInvoice { invoiceId: "#(secondInvoiceId)" }
    * def v = call cancelInvoice { invoiceId: "#(secondInvoiceId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 10. Verify Order State After Second Invoice Operations - $0 Encumbered, $50 Expended
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 0.00 && response.totalEncumbered == 0.00 && response.totalExpended == 50.00
    When method GET
    Then status 200

    # 11. Verify Encumbrance Status Is Released With $50 Expended
    * def validateEncumbranceReleased =
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
    And retry until validateEncumbranceReleased(response)
    When method GET
    Then status 200
    * def encumbranceId = response.transactions[0].id

    # 12. Verify Budget State - $950 Available After $50 Expended
    * def validateBudgetAfterExpense =
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
    And retry until validateBudgetAfterExpense(response)
    When method GET
    Then status 200

    # 13. Unrelease Encumbrance
    Given path 'finance/unrelease-encumbrance', encumbranceId
    When method POST
    Then status 204

    # 14. Verify Encumbrance Status Changed To Unreleased
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

    # 15. Verify Budget State Remains Same After Unrelease
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

    # 16. Cancel First Invoice
    * def v = call cancelInvoice { invoiceId: "#(firstInvoiceId)" }

    # 17. Verify Final Order State - $0 Encumbered, $0 Expended
    Given path 'orders/composite-orders', orderId
    And retry until response.totalEncumbered == 0.00 && response.totalExpended == 0.00
    When method GET
    Then status 200

    # 18. Verify Final Encumbrance State - $0 Amount, $0 Expended, Unreleased Status
    * def validateFinalEncumbrance =
    """
    function(response) {
      return response.amount == 0 &&
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

    # 19. Verify Final Budget State - Full $1000 Available
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
