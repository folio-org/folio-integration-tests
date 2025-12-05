# For MODINVOICE-617, https://foliotest.testrail.io/index.php?/cases/view/889713
Feature: Encumbrance Remains The Same After Cancelling A Credited Approved Invoice Release False

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

  @C889713
  @Positive
  Scenario: Encumbrance Remains The Same After Cancelling A Credited Approved Invoice Release False
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

    # 2. Create One-Time Order With Order Line
    * print '2. Create One-Time Order With Order Line'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "One-Time" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 10.00, titleOrPackage: "Test One-Time Order" }

    # 3. Open The Order
    * print '3. Open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 4. Create Credit Invoice With Release Encumbrance False
    * print '4. Create Credit Invoice With Release Encumbrance False'
    * def v = call createInvoice { id: "#(invoiceId)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: -5.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 5. Verify Order State After Credit Invoice Is Approved
    * print '5. Verify Order State After Credit Invoice Is Approved'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 10.00 && response.totalExpended == 0.00 && response.totalCredited == 0.00
    When method GET
    Then status 200

    # 6. Verify Encumbrance State After Credit Invoice Is Approved
    * print '6. Verify Encumbrance State After Credit Invoice Is Approved'
    * def validateEncumbranceAfterCredit =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 10.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.amountAwaitingPayment == -5.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterCredit(response)
    When method GET
    Then status 200

    # 7. Verify Budget State After Credit Invoice Is Approved
    * print '7. Verify Budget State After Credit Invoice Is Approved'
    * def validateBudgetAfterCredit =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 10.00 &&
             response.awaitingPayment == -5.00 &&
             response.expenditures == 0.00 &&
             response.credits == 0.00 &&
             response.available == 995.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterCredit(response)
    When method GET
    Then status 200

    # 8. Cancel The Credit Invoice
    * print '8. Cancel The Credit Invoice'
    * def v = call cancelInvoice { invoiceId: "#(invoiceId)" }

    # 9. Verify Order State After Cancelling Credit Invoice
    * print '9. Verify Order State After Cancelling Credit Invoice'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 10.00 && response.totalExpended == 0.00 && response.totalCredited == 0.00
    When method GET
    Then status 200

    # 10. Verify Encumbrance State After Cancelling Credit Invoice
    * print '10. Verify Encumbrance State After Cancelling Credit Invoice'
    * def validateEncumbranceAfterCancel =
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
    And retry until validateEncumbranceAfterCancel(response)
    When method GET
    Then status 200

    # 11. Verify Budget State After Cancelling Credit Invoice
    * print '11. Verify Budget State After Cancelling Credit Invoice'
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
