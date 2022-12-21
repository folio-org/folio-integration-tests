Feature: mod audit order_line event

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    * callonce variables
    * def id = callonce uuid

  Scenario: create OrderLine and check event saved in audit
    * def poLine = read('classpath:global/samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = id
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = globalFundId

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    Given path 'audit-data/acquisition/order-line/' + id
    When method GET
    Then status 200
    And match response.orderLineAuditEvents[0].orderLineId == id
    And match response.orderLineAuditEvents[0].action == "Create"

  Scenario: Edit orderLine and check event saved in audit

    Given path 'orders/order-lines', id
    When method GET
    Then status 200

    * def orderLineResponse = $

    Given path 'orders/order-lines', id
    And request orderLineResponse
    When method PUT
    Then status 204

    Given path 'audit-data/acquisition/order-line/' + id
    When method GET
    Then status 200
    And match response.orderLineAuditEvents[0].orderLineId == id
    And match response.orderLineAuditEvents[0].action == "Create"
    And match response.orderLineAuditEvents[1].orderLineId == id
    And match response.orderLineAuditEvents[1].action == "Edit"

