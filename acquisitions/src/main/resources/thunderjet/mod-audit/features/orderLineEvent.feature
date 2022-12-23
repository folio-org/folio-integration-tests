Feature: mod audit order_line event

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    * callonce variables
    * def id = callonce uuid

  Scenario: create Order and OrderLine and check event saved in audit
    * def vendor = karate.get('vendor', globalVendorId)
    * def orderType = karate.get('orderType', 'One-Time')
    * def ongoing = karate.get('ongoing', null)
    * def reEncumber = karate.get('reEncumber', false)

    Given path 'orders/composite-orders'
    And request
    """
    {
      id: #(id),
      vendor: #(vendor),
      orderType: #(orderType),
      ongoing: #(ongoing),
      reEncumber: #(reEncumber)
    }
    """
    When method POST
    Then status 201

    Given path 'orders/composite-orders', id
    When method GET
    Then status 200

    * def orderId = $.id

    * def poLine = read('classpath:samples/mod-orders/orderLines/order-line-audit.json')
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

  Scenario: PUT orderLine and check 2 events saved in audit

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
    And match response.totalItems == 2

