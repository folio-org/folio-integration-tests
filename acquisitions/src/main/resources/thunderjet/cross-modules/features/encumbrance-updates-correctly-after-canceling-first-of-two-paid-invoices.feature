# For MODINVOICE-616, https://foliotest.testrail.io//index.php?/cases/view/870004
Feature: Encumbrance Updates Correctly After Canceling First Of Two Paid Invoices

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

  @C870004
  @Positive
  Scenario: Encumbrance Updates Correctly After Canceling First Of Two Paid Invoices
    # Generate unique identifiers for this test scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoice1Id = call uuid
    * def invoice1LineId = call uuid
    * def invoice2Id = call uuid
    * def invoice2LineId = call uuid

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

    # 4. Create Invoice #1 With $150 Amount And Pay It
    * print '4. Create Invoice #1 With $150 Amount And Pay It'
    * def v = call createInvoice { id: "#(invoice1Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice1LineId)", invoiceId: "#(invoice1Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 150.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice1Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice1Id)" }

    # 5. Create Invoice #2 With $10 Amount And Pay It
    * print '5. Create Invoice #2 With $10 Amount And Pay It'
    * def v = call createInvoice { id: "#(invoice2Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoice2LineId)", invoiceId: "#(invoice2Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 10.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice2Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice2Id)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 6. Verify Order State After Both Invoices Are Paid
    * print '6. Verify Order State After Both Invoices Are Paid'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 100.00 && response.totalEncumbered == 0.00 && response.totalExpended == 160.00
    When method GET
    Then status 200

    # 7. Cancel Invoice #1
    * print '7. Cancel Invoice #1'
    * def v = call cancelInvoice { invoiceId: "#(invoice1Id)" }

    # 8. Verify Encumbrance Details After Canceling Invoice #1
    * print '8. Verify Encumbrance Details After Canceling Invoice #1'
    * def validateEncumbranceAfterCancel1 =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 90.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 100.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 10.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterCancel1(response)
    When method GET
    Then status 200

    # 9. Verify Budget State After Canceling Invoice #1
    * print '9. Verify Budget State After Canceling Invoice #1'
    * def validateBudgetAfterCancel1 =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 90.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 10.00 &&
             response.credits == 0.00 &&
             response.available == 900.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterCancel1(response)
    When method GET
    Then status 200

    # 10. Cancel Invoice #2
    * print '10. Cancel Invoice #2'
    * def v = call cancelInvoice { invoiceId: "#(invoice2Id)" }

    # 11. Verify Encumbrance Details After Canceling Invoice #2
    * print '11. Verify Encumbrance Details After Canceling Invoice #2'
    * def validateEncumbranceAfterCancel2 =
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
    And retry until validateEncumbranceAfterCancel2(response)
    When method GET
    Then status 200

    # 12. Verify Final Budget State After Canceling Invoice #2
    * print '12. Verify Final Budget State After Canceling Invoice #2'
    * def validateBudgetAfterCancel2 =
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
    And retry until validateBudgetAfterCancel2(response)
    When method GET
    Then status 200
