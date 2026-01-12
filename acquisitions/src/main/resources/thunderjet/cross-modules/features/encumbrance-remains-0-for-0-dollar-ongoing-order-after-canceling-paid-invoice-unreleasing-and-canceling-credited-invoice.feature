# For MODINVOICE-608, MODINVOICE-613, https://foliotest.testrail.io/index.php?/cases/view/844254
Feature: Encumbrance remains 0 for an $0 Ongoing order after canceling a paid invoice, unreleasing encumbrance, and canceling another credited invoice (release encumbrance = true)

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

  @C844254
  @Positive
  Scenario: Encumbrance remains 0 for an $0 Ongoing order after canceling a paid invoice, unreleasing encumbrance, and canceling another credited invoice (release encumbrance = true)
    # Generate unique identifiers for this test scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def creditInvoice1Id = call uuid
    * def creditInvoiceLine1Id = call uuid
    * def invoice2Id = call uuid
    * def invoiceLine2Id = call uuid

    # 1. Create Fund And Budget with $1000 allocation
    * print '1. Create Fund And Budget with $1000 allocation'
    * def v = call createFund { id: "#(fundId)", name: "Zero Dollar Ongoing Order Credit Test Fund" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 2. Create Ongoing Order With Order Line ($0 total cost)
    * print '2. Create Ongoing Order With Order Line ($0 total cost)'
    * def ongoingConfig = { "interval": 123, "isSubscription": false }
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "Ongoing", ongoing: "#(ongoingConfig)" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 0.00, titleOrPackage: "Test Zero Dollar Ongoing Order Credit" }

    # 3. Open The Order
    * print '3. Open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 4. Verify Order Is Open with $0 encumbrance
    * print '4. Verify Order Is Open with $0 encumbrance'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 0.00 && response.totalEncumbered == 0.00 && response.totalExpended == 0.00
    When method GET
    Then status 200

    # 5. Create Credit Invoice #1 (-$5, release encumbrance = true)
    * print '5. Create Credit Invoice #1 (-$5, release encumbrance = true)'
    * def v = call createInvoice { id: "#(creditInvoice1Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(creditInvoiceLine1Id)", invoiceId: "#(creditInvoice1Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: -5.00, releaseEncumbrance: true }
    * def v = call approveInvoice { invoiceId: "#(creditInvoice1Id)" }
    * def v = call payInvoice { invoiceId: "#(creditInvoice1Id)" }

    # 6. Create Invoice #2 ($10, release encumbrance = true) and cancel it
    * print '6. Create Invoice #2 ($10, release encumbrance = true) and cancel it'
    * def v = call createInvoice { id: "#(invoice2Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLine2Id)", invoiceId: "#(invoice2Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 10.00, releaseEncumbrance: true }
    * def v = call approveInvoice { invoiceId: "#(invoice2Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice2Id)" }
    * def v = call cancelInvoice { invoiceId: "#(invoice2Id)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 7. Verify Purchase Order details - Total encumbered should be $0.00, Total credited should be $5.00
    * print '7. Verify Purchase Order details - Total encumbered should be $0.00, Total credited should be $5.00'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 0.00 && response.totalEncumbered == 0.00 && response.totalExpended == 0.00 && response.totalCredited == 5.00
    When method GET
    Then status 200

    # 8. Verify Encumbrance transaction details - Amount should be $0.00, Status should be Released
    * print '8. Verify Encumbrance transaction details - Amount should be $0.00, Status should be Released'
    * def validateZeroEncumbranceReleased =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 0.00 &&
             transaction.encumbrance.status == 'Released' &&
             transaction.encumbrance.initialAmountEncumbered == 0.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateZeroEncumbranceReleased(response)
    When method GET
    Then status 200
    * def encumbranceId = response.transactions[0].id

    # 9. Verify Budget state - Encumbered should be $0.00, Credited should be $5.00, Available should be $1005.00
    * print '9. Verify Budget state - Encumbered should be $0.00, Credited should be $5.00, Available should be $1005.00'
    * def validateBudgetWithCredit =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 0.00 &&
             response.credits == 5.00 &&
             response.unavailable == 0.00 &&
             response.available == 1005.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetWithCredit(response)
    When method GET
    Then status 200

    # 10. Unrelease encumbrance
    * print '10. Unrelease encumbrance'
    Given path 'finance/unrelease-encumbrance', encumbranceId
    When method POST
    Then status 204

    # 11. Verify Encumbrance after unreleasing - Amount should remain $0.00, Status should be Unreleased
    * print '11. Verify Encumbrance after unreleasing - Amount should remain $0.00, Status should be Unreleased'
    * def validateZeroEncumbranceUnreleased =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 0.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 0.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateZeroEncumbranceUnreleased(response)
    When method GET
    Then status 200

    # 12. Verify Budget state after unreleasing - Should remain the same
    * print '12. Verify Budget state after unreleasing - Should remain the same'
    * def validateBudgetAfterUnrelease =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 0.00 &&
             response.credits == 5.00 &&
             response.unavailable == 0.00 &&
             response.available == 1005.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterUnrelease(response)
    When method GET
    Then status 200

    # 13. Cancel Credit Invoice #1
    * print '13. Cancel Credit Invoice #1'
    * def v = call cancelInvoice { invoiceId: "#(creditInvoice1Id)" }

    # Verify Credit Invoice #1 status after cancellation
    * print 'Verify Credit Invoice #1 status after cancellation'
    Given path 'invoice/invoices', creditInvoice1Id
    And retry until response.status == 'Cancelled'
    When method GET
    Then status 200

    # 14. Verify Encumbrance after credit cancellation - Amount should remain $0.00, Status should be Unreleased
    * print '14. Verify Encumbrance after credit cancellation - Amount should remain $0.00, Status should be Unreleased'
    * def validateZeroEncumbranceAfterCreditCancel =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 0.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 0.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateZeroEncumbranceAfterCreditCancel(response)
    When method GET
    Then status 200

    # 15. Verify Final Budget state - All amounts should return to original state
    * print '15. Verify Final Budget state - All amounts should return to original state'
    * def validateFinalBudgetState =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 0.00 &&
             response.credits == 0.00 &&
             response.unavailable == 0.00 &&
             response.available == 1000.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateFinalBudgetState(response)
    When method GET
    Then status 200
