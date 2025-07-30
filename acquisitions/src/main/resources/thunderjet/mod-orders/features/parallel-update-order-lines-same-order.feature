# For MODFISTO-260 and MODFISTO-432
# This should be executed with at least 5 threads
Feature: Update order lines for an open order in parallel

  Background:
    # This part is called once before scenarios are executed. It's important that all scenarios start at the same time,
    # so all scripts must be called with callonce.
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId1 = callonce uuid4
    * def poLineId2 = callonce uuid5
    * def poLineId3 = callonce uuid6
    * def poLineId4 = callonce uuid7
    * def poLineId5 = callonce uuid8

    * configure headers = headersAdmin
    * callonce createFund { 'id': '#(fundId)' }
    * callonce createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)' }

    * configure headers = headersUser
    * callonce createOrder { id: "#(orderId)" }
    * callonce createOrderLine { id: "#(poLineId1)", orderId: "#(orderId)", fundId: "#(fundId)" }
    * callonce createOrderLine { id: "#(poLineId2)", orderId: "#(orderId)", fundId: "#(fundId)" }
    * callonce createOrderLine { id: "#(poLineId3)", orderId: "#(orderId)", fundId: "#(fundId)" }
    * callonce createOrderLine { id: "#(poLineId4)", orderId: "#(orderId)", fundId: "#(fundId)" }
    * callonce createOrderLine { id: "#(poLineId5)", orderId: "#(orderId)", fundId: "#(fundId)" }
    * callonce openOrder { orderId: "#(orderId)" }


  Scenario Outline: Update line <lineNumber>
    * def lineNumber = <lineNumber>
    * def poLineId = <poLineId>
    * def listUnitPrice = <listUnitPrice>
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $

    * set poLine.cost.listUnitPrice = listUnitPrice
    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204

    * print "Finished updating line" + lineNumber


    Examples:
      | lineNumber | poLineId  | listUnitPrice |
      | 1          | poLineId1 | 11            |
      | 2          | poLineId2 | 12            |
      | 3          | poLineId3 | 13            |
      | 4          | poLineId4 | 14            |
      | 5          | poLineId5 | 15            |
