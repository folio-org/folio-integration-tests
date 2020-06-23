Feature: Verify once poline fully paid and received order should be closed

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'test_orders'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * print okapitokenAdmin

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

    * def orderId = callonce uuid
    * def poLineId = callonce uuid

    * def poNumber = '10000000'

    * configure retry = { count: 4, interval: 1000 }

  Scenario: Create composite order
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: 'c6dace5d-4574-411e-8ba1-036102fcdc9b',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201

  Scenario: Create order line
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/minimal-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.poLineNumber = poNumber + '-1'
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

  Scenario: Get poLine and update payment and receipt status
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLineResponse = $
    * set poLineResponse.paymentStatus = 'Fully Paid'
    * set poLineResponse.receiptStatus = 'Fully Received'

    Given path 'orders/order-lines', poLineId
    And request poLineResponse
    When method PUT
    Then status 204

  Scenario: Check that order closed
    Given path 'orders/composite-orders', orderId
    When method GET
    And retry until response.workflowStatus == 'Closed'
    Then status 200

    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    And match $.workflowStatus == 'Closed'

  Scenario: delete poline
    Given path 'orders/order-lines', poLineId
    When method DELETE
    Then status 204

  Scenario: delete composite orders
    Given path 'orders/composite-orders', orderId
    When method DELETE
    Then status 204

