# For MODORDERS-841, MODORDERS-800, MODORDERS-834, FAT-5128, https://foliotest.testrail.io/index.php?/cases/view/375290
Feature: Encumbrance And Budget Updated Correctly After Editing Fund Distribution And Increasing Cost With Paid Invoice

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
  Scenario: Encumbrance And Budget Updated Correctly After Editing Fund Distribution And Increasing Cost With Paid Invoice
    # Generate unique identifiers for this test scenario
    * def fundAId = call uuid
    * def fundBId = call uuid
    * def budgetAId = call uuid
    * def budgetBId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid
    * def invoiceId = call uuid
    * def invoiceLineId = call uuid

    # 1. Create Fund A With $1000 Allocation
    * print '1. Create Fund A With $1000 Allocation'
    * def v = call createFund { id: "#(fundAId)", name: "Fund A" }
    * def v = call createBudget { id: "#(budgetAId)", fundId: "#(fundAId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 2. Create Fund B With $1000 Allocation
    * print '2. Create Fund B With $1000 Allocation'
    * def v = call createFund { id: "#(fundBId)", name: "Fund B" }
    * def v = call createBudget { id: "#(budgetBId)", fundId: "#(fundBId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 3. Create One-Time Order With Re-Encumber Option Enabled
    * print '3. Create One-Time Order With Re-Encumber Option Enabled'
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "One-Time", reEncumber: true }

    # 4. Create Order Line With Fund A And $50 Total Cost
    * print '4. Create Order Line With Fund A And $50 Total Cost'
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundAId)", listUnitPrice: 50.00, titleOrPackage: "Test One-Time Order" }

    # 5. Open The Order
    * print '5. Open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    # 6. Create Invoice With $50 Amount And Release Encumbrance True
    * print '6. Create Invoice With $50 Amount And Release Encumbrance True'
    * def v = call createInvoice { id: "#(invoiceId)", fiscalYearId: "#(globalFiscalYearId)" }
    * def v = call createInvoiceLine { invoiceLineId: "#(invoiceLineId)", invoiceId: "#(invoiceId)", poLineId: "#(orderLineId)", fundId: "#(fundAId)", total: 50.00, releaseEncumbrance: true }

    # 7. Approve And Pay The Invoice
    * print '7. Approve And Pay The Invoice'
    * def v = call approveInvoice { invoiceId: "#(invoiceId)" }
    * def v = call payInvoice { invoiceId: "#(invoiceId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 8. Verify Order Is Open
    * print '8. Verify Order Is Open'
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match response.workflowStatus == 'Open'

    # 9. Verify PO Line Fund Distribution Has Fund A With $0 Current Encumbrance
    * print '9. Verify PO Line Fund Distribution Has Fund A With $0 Current Encumbrance'
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    And match response.fundDistribution[0].fundId == fundAId
    And match response.fundDistribution[0].value == 100
    And match response.cost.listUnitPrice == 50.00

    # 10. Change Fund From Fund A To Fund B And Increase Price To $70
    * print '10. Change Fund From Fund A To Fund B And Increase Price To $70'
    * def poLine = response
    * set poLine.cost.listUnitPrice = 70.00
    * set poLine.fundDistribution[0].fundId = fundBId
    * set poLine.fundDistribution[0].code = fundBId
    * remove poLine.fundDistribution[0].encumbrance
    Given path 'orders/order-lines', orderLineId
    And request poLine
    When method PUT
    Then status 204

    # 11. Verify PO Line Fund Distribution Updated With Fund B
    * print '11. Verify PO Line Fund Distribution Updated With Fund B'
    Given path 'orders/order-lines', orderLineId
    When method GET
    Then status 200
    And match response.fundDistribution[0].fundId == fundBId
    And match response.cost.listUnitPrice == 70.00

    # 12. Verify Encumbrance Transaction For Fund B (Since Trillium: Amount=$0, Status=Released)
    * print '12. Verify Encumbrance Transaction For Fund B (Since Trillium: Amount=$0, Status=Released)'
    * def validateEncumbrance =
    """
    function(response) {
      var encumbrance = response.transactions.find(t => t.transactionType == 'Encumbrance' && t.fromFundId == fundBId && t.encumbrance.sourcePurchaseOrderId == orderId);
      if (!encumbrance) return false;
      return encumbrance.amount == 0.00 &&
             encumbrance.fromFundId == fundBId &&
             encumbrance.encumbrance.status == 'Released' &&
             encumbrance.encumbrance.initialAmountEncumbered == 70.00 &&
             encumbrance.encumbrance.amountAwaitingPayment == 0.00 &&
             encumbrance.encumbrance.amountExpended == 50.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + globalFiscalYearId + ' and fromFundId==' + fundBId
    And retry until validateEncumbrance(response)
    When method GET
    Then status 200

    # 13. Verify Payment Transaction For Fund A With $50 Amount
    * print '13. Verify Payment Transaction For Fund A With $50 Amount'
    * def validatePayment =
    """
    function(response) {
      var payment = response.transactions.find(t => t.transactionType == 'Payment' && t.fromFundId == fundAId && t.sourceInvoiceId == invoiceId);
      if (!payment) return false;
      return payment.amount == 50.00 &&
             payment.fromFundId == fundAId;
    }
    """
    Given path 'finance/transactions'
    And param query = 'fiscalYearId==' + globalFiscalYearId + ' and fromFundId==' + fundAId
    And retry until validatePayment(response)
    When method GET
    Then status 200

    # 14. Verify Invoice Line Fund Distribution Still Has Fund A
    * print '14. Verify Invoice Line Fund Distribution Still Has Fund A'
    Given path 'invoice/invoice-lines', invoiceLineId
    When method GET
    Then status 200
    And match response.fundDistributions[0].fundId == fundAId
    And match response.total == 50.00

    # 15. Verify Budget A Has $50 Expended And $0 Encumbered
    * print '15. Verify Budget A Has $50 Expended And $0 Encumbered'
    * def validateBudgetA =
    """
    function(response) {
      return response.unavailable == 50.00 &&
             response.expenditures == 50.00 &&
             response.encumbered == 0.00;
    }
    """
    Given path 'finance/budgets', budgetAId
    And retry until validateBudgetA(response)
    When method GET
    Then status 200

    # 16. Verify Budget B Has $0 Encumbered And $50 Expended (Since Trillium)
    * print '16. Verify Budget B Has $0 Encumbered And $50 Expended (Since Trillium)'
    * def validateBudgetB =
    """
    function(response) {
      return response.unavailable == 50.00 &&
             response.expenditures == 50.00 &&
             response.encumbered == 0.00;
    }
    """
    Given path 'finance/budgets', budgetBId
    And retry until validateBudgetB(response)
    When method GET
    Then status 200


