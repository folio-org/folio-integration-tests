# For MODAUD-145
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

    * configure retry = { count: 10, interval: 5000 }


  Scenario: mod audit order_line events
    * def orderId = call uuid
    * def poLineId1 = call uuid
    * def fundId = call uuid
    * def budgetId = call uuid

    # 1. Create Order and OrderLines
    * def v = call createOrder { id: #(orderId) }
    * def v = call createOrderLine { id: #(poLineId1), orderId: #(orderId), fundId: #(fundId) }

    # 2. Check event saved in audit
    * configure headers = headersAdmin
    Given path 'audit-data/acquisition/order-line/', poLineId1
    And retry until response.totalItems == 1
    When method GET
    Then status 200

    And match response.orderLineAuditEvents[0].orderLineId == poLineId1
    And match response.orderLineAuditEvents[0].action == "Create"

    # 3. PUT orderLine
    * configure headers = headersUser
    * def v = call updateOrderLine { id: '#(poLineId1)' }
    * configure headers = headersUser

    # 4. Check 2 events saved in audit
    * configure headers = headersAdmin
    Given path 'audit-data/acquisition/order-line/', poLineId1
    And retry until response.totalItems == 2
    When method GET
    Then status 200

    And match response.orderLineAuditEvents[0].orderLineId == poLineId1
    And match response.totalItems == 2
