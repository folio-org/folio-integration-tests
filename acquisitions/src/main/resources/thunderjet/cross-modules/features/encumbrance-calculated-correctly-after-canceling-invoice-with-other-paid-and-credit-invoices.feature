# For MODINVOICE-616, https://foliotest.testrail.io//index.php?/cases/view/877073
Feature: Encumbrance Calculated Correctly After Canceling Invoice With Other Paid And Credit Invoices

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

  @C877073
  @Positive
  Scenario: Encumbrance Calculated Correctly After Canceling Invoice With Other Paid And Credit Invoices
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
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 100.00, titleOrPackage: "Test One-time Order" }

    # 3. Open The Order
    * print '3. Open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 4. Create Invoice #1 With $20 Amount And Pay It
    * print '4. Create Invoice #1 With $20 Amount And Pay It'
    * def v = call createInvoice { id: "#(invoice1Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice1LineId)", invoiceId: "#(invoice1Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 20.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice1Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice1Id)" }

    # 5. Create Credit Invoice #2 With -$10 Amount And Pay It
    * print '5. Create Credit Invoice #2 With -$10 Amount And Pay It'
    * def v = call createInvoice { id: "#(invoice2Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice2LineId)", invoiceId: "#(invoice2Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: -10.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice2Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice2Id)" }

    # 6. Cancel Invoice #1
    * print '6. Cancel Invoice #1'
    * def v = call cancelInvoice { invoiceId: "#(invoice1Id)" }

    # 7. Create Invoice #3 With $30 Amount And Pay It
    * print '7. Create Invoice #3 With $30 Amount And Pay It'
    * def v = call createInvoice { id: "#(invoice3Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice3LineId)", invoiceId: "#(invoice3Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 30.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice3Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice3Id)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 8. Verify Order State After All Operations
    * print '8. Verify Order State After All Operations'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 100.00 && response.totalEncumbered == 80.00 && response.totalExpended == 30.00 && response.totalCredited == 10.00
    When method GET
    Then status 200

    # 9. Verify Encumbrance Details After Invoice #1 Cancelled And Invoice #3 Paid
    * print '9. Verify Encumbrance Details After Invoice #1 Cancelled And Invoice #3 Paid'
    * def validateEncumbranceAfterOperations =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 80.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 100.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 30.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterOperations(response)
    When method GET
    Then status 200

    # 10. Verify Budget State After All Operations
    * print '10. Verify Budget State After All Operations'
    * def validateBudgetAfterOperations =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 80.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 30.00 &&
             response.credits == 10.00 &&
             response.available == 900.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterOperations(response)
    When method GET
    Then status 200

    # 11. Cancel Credit Invoice #2
    * print '11. Cancel Credit Invoice #2'
    * def v = call cancelInvoice { invoiceId: "#(invoice2Id)" }

    # 12. Verify Encumbrance Details After Canceling Credit Invoice #2
    * print '12. Verify Encumbrance Details After Canceling Credit Invoice #2'
    * def validateEncumbranceAfterCancelCredit =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 70.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 100.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 30.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterCancelCredit(response)
    When method GET
    Then status 200

    # 13. Verify Budget State After Canceling Credit Invoice #2
    * print '13. Verify Budget State After Canceling Credit Invoice #2'
    * def validateBudgetAfterCancelCredit =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 70.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 30.00 &&
             response.credits == 0.00 &&
             response.available == 900.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterCancelCredit(response)
    When method GET
    Then status 200

    # 14. Cancel Invoice #3
    * print '14. Cancel Invoice #3'
    * def v = call cancelInvoice { invoiceId: "#(invoice3Id)" }

    # 15. Verify Encumbrance Details After Canceling Invoice #3
    * print '15. Verify Encumbrance Details After Canceling Invoice #3'
    * def validateEncumbranceFinal =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 100.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 100.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceFinal(response)
    When method GET
    Then status 200

    # 16. Verify Final Budget State After Canceling Invoice #3
    * print '16. Verify Final Budget State After Canceling Invoice #3'
    * def validateBudgetFinal =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 100.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 0.00 &&
             response.credits == 0.00 &&
             response.available == 900.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetFinal(response)
    When method GET
    Then status 200
