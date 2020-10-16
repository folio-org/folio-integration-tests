Feature: Verify once order is opened or poline is updated, encumbrance inherit poline's tags

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

    # load global variables
    * callonce variables

    * def orderId = callonce uuid1
    * def poLineId = callonce uuid2

    * configure retry = { count: 4, interval: 1000 }

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
    * set orderLine.collection = false
    * set orderLine.rush = false
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.tags.tagList = [ "created" ]

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

  Scenario: Verify created encumbrance
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePoLineId==' + poLineId
    When method get
    Then status 200
    And match response.transactions[0].tags.tagList == [ "created" ]

  Scenario: Update order line
    Given path 'orders/order-lines', poLineId
    When method get
    Then status 200

    * def orderLine = $
    * set orderLine.cost.listUnitPrice = 10
    * set orderLine.fundDistribution =
    """
    [
      {
        "fundId": "5e4fbdab-f1b1-4be8-9c33-d3c41ec9a696",
        "distributionType": "percentage",
        "value": 90.0
      },
      {
        "fundId": "5e4fbdab-f1b1-4be8-9c33-d3c41ec9a698",
        "distributionType": "percentage",
        "value": 10.0
      }
    ]
    """
    * set orderLine.tags.tagList = [ "updated" ]

    Given path 'orders/order-lines', poLineId
    And request orderLine
    When method put
    Then status 204

  Scenario: Verify updated encumbrances
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePoLineId==' + poLineId
    When method get
    Then status 200
    And match response.totalRecords == 2
    And match response.transactions[0].tags.tagList == [ "updated" ]
    And match response.transactions[1].tags.tagList == [ "updated" ]