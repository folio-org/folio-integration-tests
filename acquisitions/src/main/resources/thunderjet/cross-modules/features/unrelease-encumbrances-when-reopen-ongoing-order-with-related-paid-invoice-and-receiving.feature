# For MODINVOICE-608, MODINVOICE-613, https://foliotest.testrail.io/index.php?/cases/view/356782
Feature: Unrelease Encumbrances When Reopen Ongoing Order With Related Paid Invoice And Receiving

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
  Scenario: Unrelease Encumbrances When Reopen Ongoing Order With Related Paid Invoice And Receiving
    # Generate unique identifiers for this test scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create Fund And Budget
    * def v = call createFund { id: "#(fundId)", name: "Encumbrance Test Fund" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 2. Create Ongoing Order With Order Line
    * def ongoingConfig = { "interval": 123, "isSubscription": false }
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "Ongoing", ongoing: "#(ongoingConfig)" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 5.00, titleOrPackage: "Test Ongoing Order" }

    # 3. Open The Order
    * def v = call openOrder { orderId: "#(orderId)" }

    # 4. Verify Budget After Opening Order
    * def validateBudgetAfterOpen =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 5.00 &&
             response.expenditures == 0.00 &&
             response.awaitingPayment == 0.00 &&
             response.available == 995.00;
    }
    """
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId
    And retry until validateBudgetAfterOpen(response.budgets[0])
    When method GET
    Then status 200

    # 5. Create And Pay Invoice With Release Encumbrance False
    * def v = call createInvoice { id: "#(invoiceId)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 5.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }
    * def v = call payInvoice { invoiceId: "#(invoiceId)" }

    # 6. Verify Budget After Payment
    * def validateBudgetAfterPayment =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 0.00 &&
             response.expenditures == 5.00 &&
             response.awaitingPayment == 0.00 &&
             response.available == 995.00;
    }
    """
    Given path 'finance/budgets'
    And param query = 'fundId==' + fundId
    And retry until validateBudgetAfterPayment(response.budgets[0])
    When method GET
    Then status 200

    # 7. Verify Encumbrance Status After Payment
    * def validateEncumbranceAfterPayment =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 0.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 5.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 5.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterPayment(response)
    When method GET
    Then status 200

    # 8. Cancel The Order
    * def v = call cancelOrder { orderId: "#(orderId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 9. Reopen The Ongoing Order
    * def v = call openOrder { orderId: "#(orderId)" }

    # 10. Verify Order Status After Reopening
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 5.00 && response.totalEncumbered == 0.00 && response.totalExpended == 5.00
    When method GET
    Then status 200

    # 11. Verify Order Line Status After Reopening - Payment Status Ongoing, Receipt Status Ongoing
    Given path 'orders/order-lines', orderLineId
    And retry until response.paymentStatus == 'Ongoing' && response.receiptStatus == 'Ongoing' && response.cost.listUnitPrice == 5.00
    When method GET
    Then status 200

    # 12. Verify Encumbrance Status Is Unreleased With Zero Amount
    * def validateUnreleasedEncumbrance =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 0.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 5.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 5.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateUnreleasedEncumbrance(response)
    When method GET
    Then status 200
