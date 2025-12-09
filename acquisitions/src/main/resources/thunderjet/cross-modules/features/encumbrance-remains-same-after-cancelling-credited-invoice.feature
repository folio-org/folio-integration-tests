# For MODINVOICE-608, MODINVOICE-613, https://foliotest.testrail.io/index.php?/cases/view/852110
Feature: Encumbrance Remains The Same After Cancelling Credited Invoice

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

  @C852110
  @Positive
  Scenario: Encumbrance Remains The Same After Cancelling Credited Invoice
    # Generate unique identifiers for this test scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create Fund And Budget
    * print '1. Create Fund And Budget'
    * def v = call createFund { id: "#(fundId)", name: "Encumbrance Test Fund" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 2. Create Ongoing Order With Order Line
    * print '2. Create Ongoing Order With Order Line'
    * def ongoingConfig = { "interval": 123, "isSubscription": false }
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "Ongoing", ongoing: "#(ongoingConfig)" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 10.00, titleOrPackage: "Test Ongoing Order" }

    # 3. Open The Order
    * print '3. Open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 4. Verify Order Is Open And Initial Encumbrance
    * print '4. Verify Order Is Open And Initial Encumbrance'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 10.00 && response.totalExpended == 0.00
    When method GET
    Then status 200

    # 5. Create Credited Invoice With Release Encumbrance False
    * print '5. Create Credited Invoice With Release Encumbrance False'
    * def v = call createInvoice { id: "#(invoiceId)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: -5.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }
    * def v = call payInvoice { invoiceId: "#(invoiceId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 6. Verify Order
    * print '6. Verify Order'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 10.00 && response.totalExpended == 0.00 && response.totalCredited == 5.00
    When method GET
    Then status 200

    # 7. Verify Encumbrance State After Payment
    * print '7. Verify Encumbrance State After Payment'
    * def validateEncumbranceUnreleased =
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
    And retry until validateEncumbranceUnreleased(response)
    When method GET
    Then status 200

    # 8. Verify Budget State After Payment
    * print '8. Verify Budget State After Payment'
    * def validateBudgetAfterCredit =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 10.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 0.00 &&
             response.credits == 5.00 &&
             response.available == 995.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterCredit(response)
    When method GET
    Then status 200

    # 9. Cancel The Invoice
    * print '9. Cancel The Invoice'
    * def v = call cancelInvoice { invoiceId: "#(invoiceId)" }

    # 10. Verify Invoice Status After Cancellation
    * print '10. Verify Invoice Status After Cancellation'
    Given path 'invoice/invoices', invoiceId
    And retry until response.status == 'Cancelled'
    When method GET
    Then status 200

    # 11. Verify Encumbrance State After Invoice Cancellation
    * print '11. Verify Encumbrance State After Invoice Cancellation'
    * def validateEncumbranceUnreleased =
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
    And retry until validateEncumbranceUnreleased(response)
    When method GET
    Then status 200

    # 12. Verify Budget State After Invoice Cancellation
    * print '12. Verify Budget State After Invoice Cancellation'
    * def validateBudgetAfterCancel =
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
    And retry until validateBudgetAfterCancel(response)
    When method GET
    Then status 200
