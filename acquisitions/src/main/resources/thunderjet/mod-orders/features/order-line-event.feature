@parallel=false
#https://issues.folio.org/browse/MODAUD-145
Feature: mod audit order_line events

  Background:
    * print karate.info.scenarioName

    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    * callonce variables
    * def orderId = callonce uuid
    * def poLineId1 = callonce uuid
    * def fundId = callonce uuid
    * def budgetId = callonce uuid

  Scenario: Create Order and OrderLines
    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-audit-order-line.feature')
    * callonce createOrder { id: #(orderId) }
    * callonce createOrderLine { id: #(poLineId1), orderId: #(orderId), fundId: #(fundId) }

    # we need pause because transactional outbox implementation fetches events each 2 seconds to send them to kafka
    * call pause 2000

  Scenario: Check event saved in audit
    Given path 'audit-data/acquisition/order-line/', poLineId1
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

    # we need pause because transactional outbox implementation fetches events each 2 seconds to send them to kafka
    * call pause 2000

    Scenario: Check 2 events saved in audit
    Given path 'audit-data/acquisition/order-line/', poLineId1
    When method GET
    Then status 200

    And match response.orderLineAuditEvents[0].orderLineId == poLineId1
    And match response.totalItems == 2

