@parallel=false
# for https://issues.folio.org/browse/MODORDERS-699
Feature: Cancel and delete order

  Background:
    * print karate.info.scenarioName

    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId1 = callonce uuid4
    * def poLineId2 = callonce uuid5


  Scenario: Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: #(fundId) }
    * def v = call createBudget { id: #(budgetId), fundId: #(fundId), allocated: 1000 }


  Scenario: Create an order
    * def v = callonce createOrder { id: #(orderId) }


  Scenario: Create order lines
    * def v = callonce createOrderLine { id: #(poLineId1), orderId: #(orderId), fundId: #(fundId) }
    * def v = callonce createOrderLine { id: #(poLineId2), orderId: #(orderId), fundId: #(fundId) }


  Scenario: Open the order
    * def v = callonce openOrder { orderId: "#(orderId)" }


  Scenario: Cancel the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Closed'
    * set order.closeReason = { reason: 'Cancelled' }

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204


  Scenario: Delete the order
    Given  path 'orders/composite-orders/', orderId
    When method DELETE
    Then status 204


  Scenario: Check the encumbrances were deleted
    * configure headers = headersAdmin
    Given path '/finance/transactions'
    And param query = 'encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    And match $.totalRecords == 0
