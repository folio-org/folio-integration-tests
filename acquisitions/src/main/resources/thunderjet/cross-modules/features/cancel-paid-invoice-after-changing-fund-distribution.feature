# For MODINVOICE-615, https://foliotest.testrail.io/index.php?/cases/view/895660
Feature: Cancel A Paid Invoice After Changing Fund Distribution In The PO Line

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
  Scenario: Cancel A Paid Invoice After Changing Fund Distribution In The PO Line
    # Generate unique identifiers for this test scenario
    * def fundIdA = call uuid
    * def fundIdB = call uuid
    * def budgetIdA = call uuid
    * def budgetIdB = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create Fund A And Budget A With $1000 Allocation
    * print '1. Create Fund A And Budget A With $1000 Allocation'
    * def v = call createFund { id: "#(fundIdA)", name: "Fund A" }
    * def v = call createBudget { id: "#(budgetIdA)", fundId: "#(fundIdA)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 2. Create Fund B And Budget B With $1000 Allocation
    * print '2. Create Fund B And Budget B With $1000 Allocation'
    * def v = call createFund { id: "#(fundIdB)", name: "Fund B" }
    * def v = call createBudget { id: "#(budgetIdB)", fundId: "#(fundIdB)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 3. Create One-Time Order With Order Line Using Fund A And $10 Total Cost
    * print '3. Create One-Time Order With Order Line Using Fund A And $10 Total Cost'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "One-Time" }
    * def v = call createOrderLine { id: "#(poLineId)", orderId: "#(orderId)", fundId: "#(fundIdA)", listUnitPrice: 10.00 }

    # 4. Open The Order
    * print '4. Open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 5. Get Encumbrance ID From Order Line
    * print '5. Get Encumbrance ID From Order Line'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def encumbranceId = response.fundDistribution[0].encumbrance

    # 6. Create Invoice With Invoice Line Linked To PO Line, Release Encumbrance True
    * print '6. Create Invoice With Invoice Line Linked To PO Line, Release Encumbrance True'
    * def v = call createInvoice { id: "#(invoiceId)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(poLineId)", fundId: "#(fundIdA)", encumbranceId: "#(encumbranceId)", total: 10.00, releaseEncumbrance: true }

    # 7. Approve The Invoice
    * print '7. Approve The Invoice'
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }

    # 8. Pay The Invoice
    * print '8. Pay The Invoice'
    * def v = call payInvoice { invoiceId: "#(invoiceId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 9. Verify Order Totals - Total Encumbered $0.00, Total Expended $10.00
    * print '9. Verify Order Totals - Total Encumbered $0.00, Total Expended $10.00'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 0.00 && response.totalExpended == 10.00
    When method GET
    Then status 200

    # 10. Change Fund Distribution From Fund A To Fund B
    * print '10. Change Fund Distribution From Fund A To Fund B'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = response
    * set poLine.fundDistribution[0].fundId = fundIdB
    * set poLine.fundDistribution[0].code = fundIdB
    * remove poLine.fundDistribution[0].encumbrance
    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    # 11. Verify PO Line Shows Fund B With Current Encumbrance $0
    * print '11. Verify PO Line Shows Fund B With Current Encumbrance $0'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.fundDistribution[0].fundId == fundIdB
    * def newEncumbranceId = response.fundDistribution[0].encumbrance

    * def validateNewEncumbrance =
    """
    function(response) {
      return response.amount == 0.00 &&
             response.fromFundId == fundIdB &&
             response.transactionType == 'Encumbrance' &&
             response.encumbrance.status == 'Released';
    }
    """
    Given path 'finance/transactions', newEncumbranceId
    And retry until validateNewEncumbrance(response)
    When method GET
    Then status 200

    # 12. Cancel The Invoice
    * print '12. Cancel The Invoice'
    * def v = call cancelInvoice { invoiceId: "#(invoiceId)" }

    # 13. Verify Invoice Status Is Cancelled
    * print '13. Verify Invoice Status Is Cancelled'
    Given path 'invoice/invoices', invoiceId
    When method GET
    Then status 200
    And match response.status == 'Cancelled'

    # 14. Verify Invoice Line Shows Fund A
    * print '14. Verify Invoice Line Shows Fund A'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match response.fundDistributions[0].fundId == fundIdA
    And match response.invoiceLineStatus == 'Cancelled'

    # 15. Verify Fund A Budget - All Financial Activity Values Are $0.00
    * print '15. Verify Fund A Budget - All Financial Activity Values Are $0.00'
    * def validateFundABudget =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 0.00 &&
             response.credited == 0.00 &&
             response.unavailable == 0.00 &&
             response.overEncumbrance == 0.00 &&
             response.overExpended == 0.00 &&
             response.available == 1000.00;
    }
    """
    Given path 'finance/budgets', budgetIdA
    And retry until validateFundABudget(response)
    When method GET
    Then status 200

    # 16. Verify Fund A Payment Transaction Is Voided
    * print '16. Verify Fund A Payment Transaction Is Voided'
    * def validatePaymentVoided =
    """
    function(response) {
      return response.totalRecords > 0 &&
             response.transactions[0].amount == 0.00 &&
             response.transactions[0].voidedAmount == 10.00 &&
             response.transactions[0].invoiceCancelled == true;
    }
    """
    Given path 'finance/transactions'
    And param query = 'fromFundId==' + fundIdA + ' and transactionType==Payment'
    And retry until validatePaymentVoided(response)
    When method GET
    Then status 200

    # 17. Verify No Encumbrance Transaction For PO Line In Fund A
    * print '17. Verify No Encumbrance Transaction For PO Line In Fund A'
    Given path 'finance/transactions'
    And param query = 'fromFundId==' + fundIdA + ' and transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # 18. Verify Fund B Encumbrance - Amount $10.00, Status Unreleased
    * print '18. Verify Fund B Encumbrance - Amount $10.00, Status Unreleased'
    * def validateFundBEncumbrance =
    """
    function(response) {
      return response.amount == 10.00 &&
             response.fromFundId == fundIdB &&
             response.transactionType == 'Encumbrance' &&
             response.encumbrance.status == 'Unreleased' &&
             response.encumbrance.initialAmountEncumbered == 10.00 &&
             response.encumbrance.amountAwaitingPayment == 0.00 &&
             response.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions', newEncumbranceId
    And retry until validateFundBEncumbrance(response)
    When method GET
    Then status 200

