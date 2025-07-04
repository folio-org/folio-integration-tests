@parallel=false
Feature: Reopen an order creates encumbrances

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json, text/plain', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4

    * def closeOrderRemoveLines = read('classpath:thunderjet/mod-orders/reusable/close-order-remove-lines.feature')


  Scenario: Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: #(fundId) }
    * def v = call createBudget { id: #(budgetId), fundId: #(fundId), allocated: 1000 }


  Scenario: Create an order
    * def v = call createOrder { id: #(orderId) }


  Scenario: Create an order line
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId) }


  Scenario: Open the order
    * def v = call openOrder { orderId: #(orderId) }


  Scenario: Close the order
    * def v = call closeOrderRemoveLines { orderId: #(orderId) }


  Scenario: Check the encumbrance after closing the order
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def transaction = $.transactions[0]
    And assert transaction.amount == 0.0
    And assert transaction.encumbrance.initialAmountEncumbered == 1.0
    And assert transaction.encumbrance.status == 'Released'


  Scenario: Remove the encumbrance link in the order line and delete the encumbrance
    Given path 'orders-storage/po-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * def encumbranceId = poLine.fundDistribution[0].encumbrance
    * remove poLine.fundDistribution[0].encumbrance

    Given path 'orders-storage/po-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    * configure headers = headersAdmin
    Given path 'finance/transactions/batch-all-or-nothing'
    And request
    """
    {
      "idsOfTransactionsToDelete": [ "#(encumbranceId)" ]
    }
    """
    When method POST
    Then status 204


  Scenario: Reopen the order
    * def v = call openOrder { orderId: #(orderId) }


  Scenario: Check that the encumbrance was created and that the encumbrance link was added to the order line
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def transaction = $.transactions[0]
    And assert transaction.amount == 1.0
    And assert transaction.encumbrance.initialAmountEncumbered == 1.0
    And assert transaction.encumbrance.status == 'Unreleased'

    * configure headers = headersUser
    * call getOrderLine { poLineId: #(poLineId) }
    And match poLine.fundDistribution[0].encumbrance == transaction.id
