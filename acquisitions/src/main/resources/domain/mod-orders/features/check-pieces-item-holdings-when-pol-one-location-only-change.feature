Feature: Check creation of pieces, item , holdings for POL, when only locations change and quantity stay not change.

  Background:
    * url baseUrl
    # uncomment below line for development
    # * callonce dev {tenant: 'test_orders1'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * print okapitokenAdmin

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

    # load global variables
    * callonce variables

    * def orderId = callonce uuid1
    * def poLineId = callonce uuid2

    * configure retry = { count: 4, interval: 1000 }

  Scenario: Create One-time order
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

  Scenario: Create order line
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-mixed-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    And request orderLine
    When method POST
    Then status 201

  Scenario: Open order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

  Scenario: Retrieve order line items before update location
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    Then status 200
    * def items = $.items
    And match $.totalRecords == 2
    And match items[*].effectiveLocation.id == ["#(globalLocationsId)", "#(globalLocationsId)"]


  Scenario: Retrieve order line pieces before update location
    Given path 'orders-storage/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    * def pieces = $.pieces
    And match $.totalRecords == 2
    And match pieces[*].locationId == ["#(globalLocationsId)", "#(globalLocationsId)"]

  Scenario: Get poLine and update order line location
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLineResponse = $
    * set poLineResponse.locations[0].locationId = globalLocationsId2

    Given path 'orders/order-lines', poLineId
    And request poLineResponse
    When method PUT
    Then status 204

  Scenario: Retrieve order line items after update location
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    Then status 200
    * def items = $.items
    And match $.totalRecords == 2
    And match items[*].effectiveLocation.id == ["#(globalLocationsId2)", "#(globalLocationsId2)"]

  Scenario: Retrieve order line pieces after update location
    Given path 'orders-storage/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    * def pieces = $.pieces
    And match $.totalRecords == 2
    And match pieces[*].locationId == ["#(globalLocationsId2)", "#(globalLocationsId2)"]

  Scenario: delete poline
    Given path 'orders/order-lines', poLineId
    When method DELETE
    Then status 204

  Scenario: delete composite orders
    Given path 'orders/composite-orders', orderId
    When method DELETE
    Then status 204

