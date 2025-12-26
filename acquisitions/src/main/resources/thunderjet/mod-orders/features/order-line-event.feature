# For MODAUD-145
@parallel=false
Feature: mod audit order_line events

  Background:
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
    * def orderId = callonce uuid
    * def poLineId1 = callonce uuid
    * def fundId = callonce uuid
    * def budgetId = callonce uuid

    * configure retry = { count: 10, interval: 5000 }

  Scenario: Create Order and OrderLines
    * callonce createOrder { id: #(orderId) }
    * callonce createOrderLine { id: #(poLineId1), orderId: #(orderId), fundId: #(fundId) }


  Scenario: Check event saved in audit
    * configure headers = headersAdmin
    Given path 'audit-data/acquisition/order-line/', poLineId1
    And retry until response.totalItems == 1
    When method GET
    Then status 200

    And match response.orderLineAuditEvents[0].orderLineId == poLineId1
    And match response.orderLineAuditEvents[0].action == "Create"

  Scenario: PUT orderLine
    Given path 'orders/order-lines', poLineId1
    When method GET
    Then status 200

    * def orderLineResponse = $

    Given path 'orders/order-lines', poLineId1
    And request orderLineResponse
    When method PUT
    Then status 204

  Scenario: Check 2 events saved in audit
    * configure headers = headersAdmin
    Given path 'audit-data/acquisition/order-line/', poLineId1
    And retry until response.totalItems == 2
    When method GET
    Then status 200

    And match response.orderLineAuditEvents[0].orderLineId == poLineId1
    And match response.totalItems == 2

