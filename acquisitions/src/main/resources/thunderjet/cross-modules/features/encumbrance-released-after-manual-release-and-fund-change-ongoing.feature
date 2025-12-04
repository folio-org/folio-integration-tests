# For MODORDERS-1363, MODORDERS-1367, https://foliotest.testrail.io/index.php?/cases/view/877086
Feature: Encumbrance Is Created As Released After Releasing It Manually And Changing The Fund Distribution

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

  @C877086
  @Positive
  Scenario: Encumbrance Is Created As Released After Releasing It Manually And Changing The Fund Distribution
    # Generate unique identifiers for this test scenario
    * def fundAId = call uuid
    * def fundBId = call uuid
    * def budgetAId = call uuid
    * def budgetBId = call uuid
    * def orderId = call uuid
    * def orderLineId = call uuid

    # 1. Create Fund A And Budget A With $1000 Allocation
    * print '1. Create Fund A And Budget A With $1000 Allocation'
    * def v = call createFund { id: "#(fundAId)", name: "Fund A" }
    * def v = call createBudget { id: "#(budgetAId)", fundId: "#(fundAId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 2. Create Fund B And Budget B With $1000 Allocation
    * print '2. Create Fund B And Budget B With $1000 Allocation'
    * def v = call createFund { id: "#(fundBId)", name: "Fund B" }
    * def v = call createBudget { id: "#(budgetBId)", fundId: "#(fundBId)", fiscalYearId: "#(globalFiscalYearId)", allocated: 1000, status: "Active" }

    # 3. Create Ongoing Order With Order Line Using Fund A And $10 Total Cost
    * print '3. Create Ongoing Order With Order Line Using Fund A And $10 Total Cost'
    * def ongoingConfig = { "interval": 123, "isSubscription": false }
    * def v = call createOrder { id: "#(orderId)", vendor: "#(globalVendorId)", orderType: "Ongoing", ongoing: "#(ongoingConfig)" }
    * def v = call createOrderLine { id: "#(orderLineId)", orderId: "#(orderId)", fundId: "#(fundAId)", listUnitPrice: 10.00, titleOrPackage: "Test Ongoing Order" }

    # 4. Open The Order
    * print '4. Open The Order'
    * def v = call openOrder { orderId: "#(orderId)" }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 5. Verify Order State - $10 Encumbered, $0 Expended
    * print '5. Verify Order State - $10 Encumbered, $0 Expended'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Open' && response.totalEstimatedPrice == 10.00 && response.totalEncumbered == 10.00 && response.totalExpended == 0.00
    When method GET
    Then status 200

    # 6. Verify Encumbrance Is Unreleased With $10 Amount From Fund A
    * print '6. Verify Encumbrance Is Unreleased With $10 Amount From Fund A'
    * def validateEncumbranceUnreleased =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 10.00 &&
             transaction.fromFundId == fundAId &&
             transaction.encumbrance.status == 'Unreleased' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceUnreleased(response)
    When method GET
    Then status 200
    * def encumbranceId = response.transactions[0].id

    # 7. Release Encumbrance Manually
    * print '7. Release Encumbrance Manually'
    Given path 'finance/release-encumbrance', encumbranceId
    And request {}
    When method POST
    Then status 204

    # 8. Verify Encumbrance Status Is Released With $0 Amount
    * print '8. Verify Encumbrance Status Is Released With $0 Amount'
    * def validateEncumbranceReleased =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 0.00 &&
             transaction.fromFundId == fundAId &&
             transaction.encumbrance.status == 'Released' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateEncumbranceReleased(response)
    When method GET
    Then status 200

    # 9. Change Fund Distribution From Fund A To Fund B In The Order Line
    * print '9. Change Fund Distribution From Fund A To Fund B In The Order Line'
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

    # 10. Verify New Encumbrance Is Created As Released With $0 Amount From Fund B
    * print '10. Verify New Encumbrance Is Created As Released With $0 Amount From Fund B'
    * def validateNewEncumbranceReleased =
    """
    function(response) {
      var transaction = response.transactions[0];
      return transaction.amount == 0.00 &&
             transaction.fromFundId == fundBId &&
             transaction.encumbrance.status == 'Released' &&
             transaction.encumbrance.initialAmountEncumbered == 10.00 &&
             transaction.encumbrance.amountAwaitingPayment == 0.00 &&
             transaction.encumbrance.amountExpended == 0.00;
    }
    """
    Given path 'finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    And retry until validateNewEncumbranceReleased(response)
    When method GET
    Then status 200

    # 11. Verify Budget B Reflects Released Encumbrance - $1000 Available, $0 Encumbered
    * print '11. Verify Budget B Reflects Released Encumbrance - $1000 Available, $0 Encumbered'
    * def validateBudgetB =
    """
    function(response) {
      return response.allocated == 1000.00 &&
             response.encumbered == 0.00 &&
             response.awaitingPayment == 0.00 &&
             response.expenditures == 0.00 &&
             response.credits == 0.00 &&
             response.available == 1000.00;
    }
    """
    Given path 'finance/budgets', budgetBId
    And retry until validateBudgetB(response)
    When method GET
    Then status 200

