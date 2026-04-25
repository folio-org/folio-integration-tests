Feature: Check limit number of order lines which can be retrieved in scope of composite order

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


  Scenario: Check limit number of order lines which can be retrieved in scope of composite order
    * def orderId = call uuid
    * configure retry = { count: 999, interval: 130 }

    # 1. Create One-time order
    * def v = call createOrder { id: '#(orderId)' }

    # 2. Create order line
    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-mixed-order-line.json')
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.quantityPhysical = '2'
    * set orderLine.cost.quantityElectronic = '2'
    * set orderLine.locations[1] = { 'quantity': '2', 'locationId': '#(globalLocationsId2)', 'quantityPhysical': '1', 'quantityElectronic': '1'}

    Given path 'orders/order-lines'
    And retry until response.poLineNumber.contains('-510')
    And request orderLine
    When method POST
    Then status 201

    # 3. Retrieve order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    And match orderResponse.workflowStatus == 'Pending'
    And match orderResponse.totalItems == 2040
    And match orderResponse.totalEstimatedPrice == 7140
