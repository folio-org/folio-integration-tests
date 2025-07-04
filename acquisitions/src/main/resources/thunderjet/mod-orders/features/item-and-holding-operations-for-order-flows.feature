@parallel=false
# for https://issues.folio.org/browse/MODORDERS-820
Feature: check Items and holding process.

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

    * configure retry = { count: 10, interval: 10000 }

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4
    * def initialInstanceId = globalInstanceId1
    * def initialHoldingId = globalHoldingId4


  Scenario: Create finances
    # this is needed for instance if a previous test does a rollover which changes the global fund
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)' }

  Scenario: Create an order
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201

  Scenario: Create an order line
    * def poLine = read('classpath:samples/mod-orders/orderLines/simple-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.instanceId = initialInstanceId
    * set poLine.isPackage = false
    * set poLine.fundDistribution[0].fundId = fundId
    * remove poLine.locations[0].locationId
    * set poLine.locations[0].holdingId = initialHoldingId
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201
    * def createdLine = $
    And match $.instanceId == initialInstanceId

  Scenario: Open the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

  Scenario: Check inventory and order items after open order
    * print 'Get the instanceId and holdingId from the po line'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def instanceId = response.instanceId
    * def holdingId = response.locations[0].holdingId

    * print 'Check items'
    * configure headers = headersAdmin
    Given path 'inventory/items'
    * configure headers = headersAdmin
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2

    * print 'Check holdings'
    Given path 'holdings-storage/holdings', initialHoldingId
    * configure headers = headersAdmin
    When method GET
    Then status 200
    And assert response.id == initialHoldingId

  Scenario: unOpen the order with deleteHoldings = false
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Pending'

    Given path 'orders/composite-orders', orderId
    And param deleteHoldings = false
    And request orderResponse
    When method PUT
    Then status 204

  Scenario: Check inventory and order items after Unopen order
    * print 'Get the instanceId and holdingId from the po line'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def instanceId = response.instanceId
    * def holdingId = response.locations[0].holdingId

    * print 'Check items'
    * configure headers = headersAdmin
    Given path 'inventory/items'
    * configure headers = headersAdmin
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 0

    * print 'Check holdings'
    Given path 'holdings-storage/holdings', initialHoldingId
    * configure headers = headersAdmin
    When method GET
    And assert response.id == initialHoldingId

  Scenario: Open the order again
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

  Scenario: Check inventory and order items after open order
    * print 'Get the instanceId and holdingId from the po line'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def instanceId = response.instanceId
    * def holdingId = response.locations[0].holdingId

    * print 'Check items'
    * configure headers = headersAdmin
    Given path 'inventory/items'
    * configure headers = headersAdmin
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 2

    * print 'Check holdings'
    Given path 'holdings-storage/holdings', initialHoldingId
    * configure headers = headersAdmin
    When method GET
    Then status 200
    And assert response.id == initialHoldingId

  Scenario: unOpen the order again with deleteHoldings = true
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Pending'

    Given path 'orders/composite-orders', orderId
    And param deleteHoldings = true
    And request orderResponse
    When method PUT
    Then status 204

  Scenario: Check inventory and order items after unOpen order
    * print 'Get the instanceId and holdingId from the po line'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def instanceId = response.instanceId
    * def holdingId = response.locations[0].holdingId

    * print 'Check items'
    * configure headers = headersAdmin
    Given path 'inventory/items'
    * configure headers = headersAdmin
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 0

    * print 'Check holdings'
    Given path 'holdings-storage/holdings', initialHoldingId
    * configure headers = headersAdmin
    And retry until responseStatus == 404
    When method GET
    Then status 404

