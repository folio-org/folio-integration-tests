# For https://issues.folio.org/browse/MODFISTO-260
# This should be executed with at least 5 threads
Feature: Update order lines for an open order in parallel

  Background:
    # This part is called once before scenarios are executed. It's important that all scenarios start at the same time,
    # so all scripts must be called with callonce.
    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId1 = callonce uuid4
    * def poLineId2 = callonce uuid5
    * def poLineId3 = callonce uuid6
    * def poLineId4 = callonce uuid7
    * def poLineId5 = callonce uuid8

    * def createOrder = read('reusable/create-order.feature')
    * def createOrderLine = read('reusable/create-order-line.feature')
    * def openOrder = read('reusable/open-order.feature')

    * configure headers = headersAdmin

    * callonce createFund { 'id': '#(fundId)'}
    * callonce createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}
    * callonce createOrder { orderId: "#(orderId)" }
    * callonce createOrderLine { orderId: "#(orderId)", poLineId: "#(poLineId1)", fundId: "#(fundId)" }
    * callonce createOrderLine { orderId: "#(orderId)", poLineId: "#(poLineId2)", fundId: "#(fundId)" }
    * callonce createOrderLine { orderId: "#(orderId)", poLineId: "#(poLineId3)", fundId: "#(fundId)" }
    * callonce createOrderLine { orderId: "#(orderId)", poLineId: "#(poLineId4)", fundId: "#(fundId)" }
    * callonce createOrderLine { orderId: "#(orderId)", poLineId: "#(poLineId5)", fundId: "#(fundId)" }
    * callonce openOrder { orderId: "#(orderId)" }

    * configure headers = headersUser

  Scenario: Update line 1
    Given path 'orders/order-lines', poLineId1
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.cost.listUnitPrice = 11
    Given path 'orders/order-lines', poLineId1
    And request poLine
    When method PUT
    Then status 204

  Scenario: Update line 2
    Given path 'orders/order-lines', poLineId2
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.cost.listUnitPrice = 12
    Given path 'orders/order-lines', poLineId2
    And request poLine
    When method PUT
    Then status 204

  Scenario: Update line 3
    Given path 'orders/order-lines', poLineId3
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.cost.listUnitPrice = 13
    Given path 'orders/order-lines', poLineId3
    And request poLine
    When method PUT
    Then status 204

  Scenario: Update line 4
    Given path 'orders/order-lines', poLineId4
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.cost.listUnitPrice = 14
    Given path 'orders/order-lines', poLineId4
    And request poLine
    When method PUT
    Then status 204

  Scenario: Update line 5
    Given path 'orders/order-lines', poLineId5
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.cost.listUnitPrice = 15
    Given path 'orders/order-lines', poLineId5
    And request poLine
    When method PUT
    Then status 204
