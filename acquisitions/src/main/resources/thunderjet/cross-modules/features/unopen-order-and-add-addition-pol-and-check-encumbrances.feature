Feature: UnOpen order and add addition POL and 1 Fund. Also verify encumbrances

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'testcrossmodules'}

    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

    * configure headers = headersUser
    # load global variables
    * callonce variables

    * def orderId = callonce uuid1
    * def orderLineIdOne = callonce uuid2
    * def unOpenOrderLineId = callonce uuid3

  Scenario: Create orders
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

  Scenario Outline: Create order lines for <orderLineId>
    * def orderId = <orderId>
    * def poLineId = <orderLineId>
   Given path 'orders/order-lines'
    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    And request orderLine
    When method POST
    Then status 201

    Examples:
      | orderId | orderLineId    |
      | orderId | orderLineIdOne |

  Scenario: Open order
    # ============= get order to open ===================
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    # ============= update order to open ===================
    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

  Scenario: Check that order status Open in encumbrance after Open order
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    * def transaction = karate.jsonPath(response, "$.transactions[?(@.encumbrance.sourcePoLineId=='"+orderLineIdOne+"')]")[0]
    And match transaction.amount == 1.0
    And match transaction.currency == 'USD'
    And match transaction.encumbrance.initialAmountEncumbered == 1.0
    And match transaction.encumbrance.status == 'Unreleased'
    And match transaction.encumbrance.orderStatus == 'Open'

  Scenario: UnOpen order
    # ============= get order to open ===================
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Pending"

    # ============= update order to open ===================
    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

  Scenario: Check order workflow status is Pending after UnOpen
    # ============= get order to open ===================
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    And match orderResponse.workflowStatus == "Pending"

  Scenario: Check that order status Pending in encumbrance after UnOpen order
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    * def transaction = karate.jsonPath(response, "$.transactions[?(@.encumbrance.sourcePoLineId=='"+orderLineIdOne+"')]")[0]
    And match transaction.amount == 0
    And match transaction.currency == 'USD'
    And match transaction.encumbrance.initialAmountEncumbered == 0
    And match transaction.encumbrance.status == 'Pending'
    And match transaction.encumbrance.orderStatus == 'Pending'


  Scenario Outline: Create order lines after UnOpen order for <unOpenOrderLineId>
    * def orderId = <orderId>
    * def poLineId = <unOpenOrderLineId>
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId

    And request orderLine
    When method POST
    Then status 201

    Examples:
      | orderId | unOpenOrderLineId |
      | orderId | unOpenOrderLineId |

  Scenario: ReOpen order
    # ============= get order to open ===================
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    # ============= update order to open ===================
    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

  Scenario: Check order after ReOpen
    # ============= get order to open ===================
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

  Scenario: Check that order status Open in encumbrance after ReOpen order
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    * def encumbrance1 = karate.jsonPath(response, "$.transactions[?(@.encumbrance.sourcePoLineId=='"+orderLineIdOne+"')]")[0]
    * def encumbrance2 = karate.jsonPath(response, "$.transactions[?(@.encumbrance.sourcePoLineId=='"+unOpenOrderLineId+"')]")[0]
    And match encumbrance1.amount == 1.0
    And match encumbrance1.currency == 'USD'
    And match encumbrance1.encumbrance.initialAmountEncumbered == 1.0
    And match encumbrance1.encumbrance.status == 'Unreleased'
    And match encumbrance1.encumbrance.orderStatus == 'Open'
    And match encumbrance2.amount == 1.0
    And match encumbrance2.currency == 'USD'
    And match encumbrance2.encumbrance.initialAmountEncumbered == 1.0
    And match encumbrance2.encumbrance.status == 'Unreleased'
    And match encumbrance2.encumbrance.orderStatus == 'Open'
