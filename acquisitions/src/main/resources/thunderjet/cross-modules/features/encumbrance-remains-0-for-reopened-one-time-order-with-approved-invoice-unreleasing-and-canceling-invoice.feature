# For MODINVOICE-608, MODINVOICE-613, https://foliotest.testrail.io/index.php?/cases/view/844262
Feature: Encumbrance remains 0 for a re-opened One-time order with an approved invoice, unreleasing encumbrance, and canceling an invoice

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

  @C844262
  @Positive
  Scenario: Encumbrance remains 0 for a re-opened One-time order with an approved invoice, unreleasing encumbrance, and canceling an invoice
    # Generate unique identifiers for this test scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create Fund And Budget with $1000 allocation
    * print '1. Create Fund And Budget with $1000 allocation'
    * def v = call createFund { id: "#(fundId)", name: "Re-opened One-time Order Test Fund" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 2. Create One-time Order With Order Line ($10 total cost)
    * print '2. Create One-time Order With Order Line ($10 total cost)'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "One-Time" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 10.00, titleOrPackage: "Test One-time Order" }

    # 3. Open The Order
    * print '3. Open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 4. Verify Order Is Open with $10 encumbrance
    * print '4. Verify Order Is Open with $10 encumbrance'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 10.00 && response.totalExpended == 0.00
    When method GET
    Then status 200

    # 5. Create Invoice #1 ($50, release encumbrance = true)
    * print '5. Create Invoice #1 ($50, release encumbrance = true)'
    * def v = call createInvoice { id: "#(invoiceId)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 50.00, releaseEncumbrance: true }
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }

    # 6. Cancel The Order
    * print '6. Cancel The Order'
    * def v = call closeOrder { orderId: "#(orderId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 7. Verify Purchase Order details - Total encumbered should be $0.00 (cancelled order)
    * print '7. Verify Purchase Order details - Total encumbered should be $0.00 (cancelled order)'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Closed' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 0.00 && response.totalExpended == 0.00
    When method GET
    Then status 200

    # 8. Re-open The Order
    * print '8. Re-open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # Verify Order Is Reopened with $0 encumbered
    * print 'Verify Order Is Reopened with $0 encumbered'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 0.00 && response.totalExpended == 0.00
    When method GET
    Then status 200

    # 9. Verify Encumbrance transaction details - Amount should be $0.00, Status should be Released, $50 Awaiting Payment
    * print '9. Verify Encumbrance transaction details - Amount should be $0.00, Status should be Released, $50 Awaiting Payment'
    * def validateZeroEncumbranceReleased =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 0.00 &&
             transaction.encumbrance.status == 'Released' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.amountAwaitingPayment == 50.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateZeroEncumbranceReleased(response)
    When method GET
    Then status 200
    * def encumbranceId = response.transactions[0].id

    # 10. Verify Budget state - Encumbered should be $0.00, Awaiting Payment should be $50.00, Available should be $950.00
    * print '10. Verify Budget state - Encumbered should be $0.00, Awaiting Payment should be $50.00, Available should be $950.00'
    * def validateBudgetWithAwaitingPayment =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 50.00 &&
             response.expenditures == 0.00 &&
             response.credits == 0.00 &&
             response.unavailable == 50.00 &&
             response.available == 950.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetWithAwaitingPayment(response)
    When method GET
    Then status 200

    # 11. Unrelease encumbrance
    * print '11. Unrelease encumbrance'
    Given path 'finance/unrelease-encumbrance', encumbranceId
    When method POST
    Then status 204

    # 12. Verify Encumbrance after unreleasing - Amount should be $10.00, Status should be Unreleased
    * print '12. Verify Encumbrance after unreleasing - Amount should be $10.00, Status should be Unreleased'
    * def validateTenDollarEncumbranceUnreleased =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 10.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.amountAwaitingPayment == 50.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateTenDollarEncumbranceUnreleased(response)
    When method GET
    Then status 200

    # 13. Verify Budget state after unreleasing - Encumbered should be $10.00, Available should be $940.00
    * print '13. Verify Budget state after unreleasing - Encumbered should be $10.00, Available should be $940.00'
    * def validateBudgetAfterUnrelease =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 10.00 &&
             response.awaitingPayment == 50.00 &&
             response.expenditures == 0.00 &&
             response.credits == 0.00 &&
             response.unavailable == 60.00 &&
             response.available == 940.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterUnrelease(response)
    When method GET
    Then status 200

    # 14. Cancel Invoice #1
    * print '14. Cancel Invoice #1'
    * def v = call cancelInvoice { invoiceId: "#(invoiceId)" }

    # Verify Invoice #1 status after cancellation
    * print 'Verify Invoice #1 status after cancellation'
    Given path 'invoice/invoices', invoiceId
    And retry until response.status == 'Cancelled'
    When method GET
    Then status 200

    # 15. Verify Encumbrance after invoice cancellation - Amount should remain $10.00, Status should be Unreleased, $0 Awaiting Payment
    * print '15. Verify Encumbrance after invoice cancellation - Amount should remain $10.00, Status should be Unreleased, $0 Awaiting Payment'
    * def validateEncumbranceAfterInvoiceCancel =
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
    And retry until validateEncumbranceAfterInvoiceCancel(response)
    When method GET
    Then status 200

    # 16. Verify Final Budget state - Encumbered should remain $10.00, Awaiting Payment should be $0.00, Available should be $990.00
    * print '16. Verify Final Budget state - Encumbered should remain $10.00, Awaiting Payment should be $0.00, Available should be $990.00'
    * def validateFinalBudgetState =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 10.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 0.00 &&
             response.credits == 0.00 &&
             response.unavailable == 10.00 &&
             response.available == 990.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateFinalBudgetState(response)
    When method GET
    Then status 200
