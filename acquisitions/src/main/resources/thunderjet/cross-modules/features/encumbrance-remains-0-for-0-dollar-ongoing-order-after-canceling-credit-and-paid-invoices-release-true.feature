# For MODINVOICE-608, MODINVOICE-613, https://foliotest.testrail.io/index.php?/cases/view/864744
Feature: Encumbrance remains 0 for an $0 Ongoing order after canceling a paid credit invoice and canceling another paid invoice (release encumbrance = true)

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

  @C864744
  @Positive
  Scenario: Encumbrance remains 0 for an $0 Ongoing order after canceling a paid credit invoice and canceling another paid invoice (release encumbrance = true)
    # Generate unique identifiers for this test scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoice1Id = call uuid
    * def invoiceLine1Id = call uuid
    * def invoice2Id = call uuid
    * def invoiceLine2Id = call uuid

    # 1. Create Active Fiscal Year including current date
    * print '1. Create Active Fiscal Year including current date'
    * def fiscalYearId = globalFiscalYearId

    # 2. Create Active Ledger related to the created Fiscal year
    * print '2. Create Active Ledger related to the created Fiscal year'
    * def ledgerId = globalLedgerId

    # 3. Create Active Fund A with current budget having $1000 money allocation
    * print '3. Create Active Fund A with current budget having $1000 money allocation'
    * def v = call createFund { id: "#(fundId)", name: "Fund A - Zero Dollar Ongoing Order Test" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", fiscalYearId: "#(fiscalYearId)", allocated: 1000, status: "Active" }

    # 4. Create Ongoing order in "Open" status with one PO line, Fund A, total cost = $0
    * print '4. Create Ongoing order in "Open" status with one PO line, Fund A, total cost = $0'
    * def ongoingConfig = { "interval": 123, "isSubscription": false }
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "Ongoing", ongoing: "#(ongoingConfig)" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 0.00, titleOrPackage: "Zero Dollar Ongoing Order Test Line" }
    * def v = call openOrder { orderId: "#(orderId)" }

    # 5. Create Credit Invoice #1, Fund A, release encumbrance = true, amount = -$5
    * print '5. Create Credit Invoice #1, Fund A, release encumbrance = true, amount = -$5'
    * def v = call createInvoice { id: "#(invoice1Id)", fiscalYearId: "#(fiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLine1Id)", invoiceId: "#(invoice1Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: -5.00, releaseEncumbrance: true }
    * def v = call approveInvoice { invoiceId: "#(invoice1Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice1Id)" }

    # 6. Create Invoice #2, Fund A, release encumbrance = true, amount = $10
    * print '6. Create Invoice #2, Fund A, release encumbrance = true, amount = $10'
    * def v = call createInvoice { id: "#(invoice2Id)", fiscalYearId: "#(fiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLine2Id)", invoiceId: "#(invoice2Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 10.00, releaseEncumbrance: true }
    * def v = call approveInvoice { invoiceId: "#(invoice2Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice2Id)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 7. Verify Purchase Order details - Total encumbered should be $0.00
    * print '7. Verify Purchase Order details - Total encumbered should be $0.00'
    * def validateOrderAfterPayments =
    """
    function(response) {
      return response.workflowStatus == 'Open' &&
             response.totalEstimatedPrice == 0.00 &&
             response.totalEncumbered == 0.00 &&
             response.totalExpended == 10.00 &&
             response.totalCredited == 5.00;
    }
    """
    Given path 'orders/composite-orders', orderId
    And retry until validateOrderAfterPayments(response)
    When method GET
    Then status 200

    # 8. Cancel Credit Invoice #1
    * print '8. Cancel Credit Invoice #1'
    * def v = call cancelInvoice { invoiceId: "#(invoice1Id)" }

    # Verify Invoice #1 status is "Cancelled"
    * print 'Verify Invoice #1 status is "Cancelled"'
    Given path 'invoice/invoices', invoice1Id
    And retry until response.status == 'Cancelled'
    When method GET
    Then status 200

    # 9. Verify encumbrance transaction details after credit invoice cancellation
    * print '9. Verify encumbrance transaction details after credit invoice cancellation'
    * def validateEncumbranceAfterCreditCancel =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 0.00 &&
             transaction.encumbrance.status == 'Released' &&
             transaction.encumbrance.initialAmountEncumbered == 0.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 10.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterCreditCancel(response)
    When method GET
    Then status 200

    # 10. Verify Budget state after credit cancellation
    * print '10. Verify Budget state after credit cancellation'
    * def validateBudgetAfterCreditCancel =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 10.00 &&
             response.credits == 0.00 &&
             response.unavailable == 10.00 &&
             response.available == 990.00;
    }
    """
    Given path 'finance/budgets', budgetId
    And retry until validateBudgetAfterCreditCancel(response)
    When method GET
    Then status 200

    # 11. Cancel Invoice #2
    * print '11. Cancel Invoice #2'
    * def v = call cancelInvoice { invoiceId: "#(invoice2Id)" }

    # Verify Invoice #2 status is "Cancelled"
    * print 'Verify Invoice #2 status is "Cancelled"'
    Given path 'invoice/invoices', invoice2Id
    And retry until response.status == 'Cancelled'
    When method GET
    Then status 200

    # 12. Verify encumbrance transaction details after second invoice cancellation
    * print '12. Verify encumbrance transaction details after second invoice cancellation'
    * def validateEncumbranceAfterSecondCancel =
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
    And retry until validateEncumbranceAfterSecondCancel(response)
    When method GET
    Then status 200

    # 13. Verify Final Budget state - All amounts should return to original state
    * print '13. Verify Final Budget state - All amounts should return to original state'
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
