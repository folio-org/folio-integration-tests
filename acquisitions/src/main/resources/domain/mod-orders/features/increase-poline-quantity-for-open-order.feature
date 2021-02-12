Feature: Verify that pieces will be created for open order if user increase quantity for poline

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'test_orders'}
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

    # load global variables
    * callonce variables

    * def orderId = callonce uuid1
    * def poLineId = callonce uuid2

  Scenario: Create composite order
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

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
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

  Scenario: Verify that pieces has been created for poLine
    * configure headers = headersAdmin

    Given path 'orders-storage/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1

  Scenario: get poline and increase the quantity
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLineResponse = $
    * set poLineResponse.cost.quantityPhysical = 2
    * set poLineResponse.locations[0].quantityPhysical = 2

    Given path 'orders/order-lines', poLineId
    And request poLineResponse
    When method PUT
    Then status 204

  Scenario: Verify that pieces has been increase for poLine
    * configure headers = headersAdmin

    Given path 'orders-storage/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2

  Scenario: delete poline
    Given path 'orders/order-lines', poLineId
    When method DELETE
    Then status 204

  Scenario: delete composite orders
    Given path 'orders/composite-orders', orderId
    When method DELETE
    Then status 204

