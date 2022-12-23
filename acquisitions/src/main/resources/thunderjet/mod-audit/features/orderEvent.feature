Feature: mod audit order event

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    * callonce variables
    * def id = callonce uuid

  Scenario: create Order and check event saved in audit
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


    Given path 'audit-data/acquisition/order/' + id
    When method GET
    Then status 200
    And match response.orderAuditEvents[0].orderId == id
    And match response.orderAuditEvents[0].action == "Create"

  Scenario: PUT order and check 2 event saved in audit

    Given path 'orders/composite-orders', id
    When method GET
    Then status 200

    * def orderResponse = $

    Given path 'orders/composite-orders', id
    And request orderResponse
    When method PUT
    Then status 204

    Given path 'audit-data/acquisition/order/' + id
    When method GET
    Then status 200
    And match response.orderAuditEvents[0].orderId == id
    And match response.totalItems == 2
