@parallel=false
Feature: Edge Orders Ebsconet

  Background:
    * def testTenant = 'test_edge_orders'
    * def testUser = { tenant: '#(testTenant)', name: 'test-user', password: 'test' }
    * url baseUrl
    * def edgeHeaders = { 'Content-Type': 'application/json', 'Accept': 'application/json'  }
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def folioUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * callonce variables
    * def orderId = callonce uuid1
    * def poLineId = callonce uuid2
    * def apiKey = 'eyJzIjoia1FoWUtGYzFJMFE5bVhKNmRUWU0iLCJ0IjoidGVzdF9lZGdlX29yZGVycyIsInUiOiJ0ZXN0LXVzZXIifQ=='
    * def poNumber = '10010'
    * def poLineNumber = '10010-1'

  Scenario: Validate apiKey
    Given url edgeUrl
    And path 'orders/validate'
    And param type = 'EBSCONET'
    And param apiKey = apiKey
    And headers edgeHeaders
    When method GET
    Then status 200
    And match $.status == "Success"

  Scenario: Create Purchase Order
    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.poLineNumber = poLineNumber
    * set orderLine.purchaseOrderId = orderId
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      poNumber: '#(poNumber)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time',
      compositePoLines: [#(orderLine)]
    }
    """
    And headers folioUserHeaders
    When method POST
    Then status 201

  Scenario: Get Ebsconet Order Line with edge-orders
    Given url edgeUrl
    And path 'orders/order-lines', poLineNumber
    And param type = 'EBSCONET'
    And param apiKey = apiKey
    And headers edgeHeaders
    When method GET
    Then status 200
    And match $ ==
    """
    {
      "vendor": "testcode",
      "unitPrice": 1.0,
      "currency": "USD",
      "vendorReferenceNumbers": [
      ],
      "fundCode": "#(globalFundCode)",
      "poLineNumber": "#(poLineNumber)",
      "quantity": 1,
      "vendorAccountNumber": "1234",
      "workflowStatus": "Pending"
    }
    """

  Scenario: Put Ebsconet Order Line
    * def ebsconetOrderLine = read('classpath:samples/edge-orders/ebsconet/ebsconet-order-line.json')
    Given url edgeUrl
    And path 'orders/order-lines', poLineNumber
    And param type = 'EBSCONET'
    And param apiKey = apiKey
    And headers edgeHeaders
    And request ebsconetOrderLine
    When method PUT
    Then status 204
