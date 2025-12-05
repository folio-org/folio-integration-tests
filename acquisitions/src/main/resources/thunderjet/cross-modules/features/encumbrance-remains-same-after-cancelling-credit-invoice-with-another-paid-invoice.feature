# For MODINVOICE-487, https://foliotest.testrail.io/index.php?/cases/view/400618
Feature: Initial encumbrance amount remains the same as it was before payment after cancelling related paid credit invoice (another related paid invoice exists)

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

  @C400618
  @Positive
  Scenario: Initial encumbrance amount remains the same as it was before payment after cancelling related paid credit invoice (another related paid invoice exists)
    # Generate unique identifiers for this test scenario
    * def fundId = call uuid
    * def budgetId = call uuid
    * def ledgerId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoice1Id = call uuid
    * def invoiceLine1Id = call uuid
    * def invoice2Id = call uuid
    * def invoiceLine2Id = call uuid

    # 1. Create Active Ledger with "Enforce all budget encumbrance limits" and "Enforce all budget expenditure limits" options active
    * print '1. Create Active Ledger with "Enforce all budget encumbrance limits" and "Enforce all budget expenditure limits" options active'
    * def v = call createLedger { id: "#(ledgerId)", name: "Credit Invoice Cancel Test Ledger", fiscalYearId: "#(globalFiscalYearId)", restrictEncumbrance: true, restrictExpenditures: true }

    # 2. Create Active Fund A having current budget with $100 money allocation, "Allowable encumbrance" = 110%
    * print '2. Create Active Fund A having current budget with $100 money allocation, "Allowable encumbrance" = 110%'
    * def v = call createFund { id: "#(fundId)", name: "Fund A - Credit Invoice Cancel Test", ledgerId: "#(ledgerId)" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 100, status: "Active", allowableEncumbrance: 110 }

    # 3. Create order in "Open" status with one PO line, "Fund distribution" with "Fund A", order total amount = $110
    * print '3. Create order in "Open" status with one PO line, "Fund distribution" with "Fund A", order total amount = $110'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "One-Time" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 110.00, titleOrPackage: "Credit Invoice Cancel Test Order Line" }
    * def v = call openOrder { orderId: "#(orderId)" }

    # 4. Create Invoice #1 in "Paid" status, "Release encumbrance" option is NOT Active, "Sub-total" amount = $15
    * print '4. Create Invoice #1 in "Paid" status, "Release encumbrance" option is NOT Active, "Sub-total" amount = $15'
    * def v = call createInvoice { id: "#(invoice1Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLine1Id)", invoiceId: "#(invoice1Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: 15.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice1Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice1Id)" }

    # 5. Create Credit Invoice #2 in "Paid" status, "Release encumbrance" option is NOT Active, "Sub-total" amount = -$5
    * print '5. Create Credit Invoice #2 in "Paid" status, "Release encumbrance" option is NOT Active, "Sub-total" amount = -$5'
    * def v = call createInvoice { id: "#(invoice2Id)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLine2Id)", invoiceId: "#(invoice2Id)", poLineId: "#(orderLineId)", fundId: "#(fundId)", total: -5.00, releaseEncumbrance: false }
    * def v = call approveInvoice { invoiceId: "#(invoice2Id)" }
    * def v = call payInvoice { invoiceId: "#(invoice2Id)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 6. Cancel Invoice #2 (credit invoice)
    * print '6. Cancel Invoice #2 (credit invoice)'
    * def v = call cancelInvoice { invoiceId: "#(invoice2Id)" }

    # Verify Invoice #2 status is "Cancelled"
    * print 'Verify Invoice #2 status is "Cancelled"'
    Given path 'invoice/invoices', invoice2Id
    And retry until response.status == 'Cancelled'
    When method GET
    Then status 200

    # 7. Verify Current encumbrance transaction details - Amount = $95.00, Status = Unreleased
    * print '7. Verify Current encumbrance transaction details - Amount = $95.00, Status = Unreleased'
    * def validateEncumbranceAfterCreditCancel =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 95.00 &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 110.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 15.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceAfterCreditCancel(response)
    When method GET
    Then status 200
