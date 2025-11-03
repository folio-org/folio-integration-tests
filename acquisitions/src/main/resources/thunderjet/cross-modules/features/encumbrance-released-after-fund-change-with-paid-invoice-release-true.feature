# For MODORDERS-1363, MODORDERS-1367, https://foliotest.testrail.io/index.php?/cases/view/877085
Feature: Encumbrance Is Created As Released After Changing The Fund Distribution With Paid Invoice Release True

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
  Scenario: Encumbrance Is Created As Released After Changing The Fund Distribution With Paid Invoice Release True
    # Generate unique identifiers for this test scenario
    * def fundAId = call uuid
    * def fundBId = call uuid
    * def budgetAId = call uuid
    * def budgetBId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create Fund A And Budget A With $1000 Allocation
    * print '1. Create Fund A And Budget A With $1000 Allocation'
    * def v = call createFund { id: "#(fundAId)", name: "Fund A" }
    * def v = call createBudget { id: "#(budgetAId)", fundId: "#(fundAId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 2. Create Fund B And Budget B With $1000 Allocation
    * print '2. Create Fund B And Budget B With $1000 Allocation'
    * def v = call createFund { id: "#(fundBId)", name: "Fund B" }
    * def v = call createBudget { id: "#(budgetBId)", fundId: "#(fundBId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 3. Create One-Time Order With Order Line Using Fund A And $10 Total Cost
    * print '3. Create One-Time Order With Order Line Using Fund A And $10 Total Cost'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "One-Time" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundAId)", listUnitPrice: 10.00, titleOrPackage: "Test One-Time Order" }

    # 4. Open The Order
    * print '4. Open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 5. Create Invoice With $9 Amount And Release Encumbrance True
    * print '5. Create Invoice With $9 Amount And Release Encumbrance True'
    * def v = call createInvoice { id: "#(invoiceId)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(orderLineId)", fundId: "#(fundAId)", total: 9.00, releaseEncumbrance: true }

    # 6. Approve And Pay The Invoice
    * print '6. Approve And Pay The Invoice'
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }
    * def v = call payInvoice { invoiceId: "#(invoiceId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 7. Verify Order State - $0 Encumbered, $9 Expended
    * print '7. Verify Order State - $0 Encumbered, $9 Expended'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 0.00 && response.totalExpended == 9.00
    When method GET
    Then status 200

    # 8. Change Fund Distribution From Fund A To Fund B In The Order Line
    * print '8. Change Fund Distribution From Fund A To Fund B In The Order Line'
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    * def poLine = response
    * set poLine.fundDistribution[0].fundId = fundBId
    * set poLine.fundDistribution[0].code = fundBId
    * remove poLine.fundDistribution[0].encumbrance
    Given path 'orders/order-lines', orderLineId
    And request poLine
    When method PUT
    Then status 204

    # 9. Verify New Encumbrance Is Created As Released With $0 Amount From Fund B
    * print '9. Verify New Encumbrance Is Created As Released With $0 Amount From Fund B'
    * def validateNewEncumbranceReleased =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 0.00 &&
             transaction.fromFundId == fundBId &&
             transaction.encumbrance.status == 'Released' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 9.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateNewEncumbranceReleased(response)
    When method GET
    Then status 200


