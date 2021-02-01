Feature: Open order with manual exchange rate

  Background:
    * url baseUrl
    # uncomment below line for development
#    * callonce dev {tenant: 'test_orders'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': '*/*'  }

    * configure headers = headersUser
    # load global variables
    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2

    * def orderId = callonce uuid3
    * def orderLineIdOne = callonce uuid4
    * def orderLineIdTwo = callonce uuid5
    * def orderLineIdThree = callonce uuid6

  Scenario Outline: prepare finances for fund with <fundId> and budget with <budgetId>
    * def fundId = <fundId>
    * def budgetId = <budgetId>

    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerWithRestrictionsId)'}
    * call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 9999}

    Examples:
      | fundId | budgetId |
      | fundId | budgetId |

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

  Scenario Outline: Create order lines for <orderLineId> and <fundId>
    * def orderId = <orderId>
    * def poLineId = <orderLineId>

    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = <amount>
    * set orderLine.cost.currency = <currency>
    * set orderLine.cost.exchangeRate = <exchangeRate>
    * set orderLine.fundDistribution[0].fundId = <fundId>

    And request orderLine
    When method POST
    Then status 201

    Examples:
      | orderId | orderLineId      | fundId | exchangeRate | amount | currency |
      | orderId | orderLineIdOne   | fundId | 2.0          | 1      | 'EUR'    |
      | orderId | orderLineIdTwo   | fundId | 3.0          | 2      | 'EUR'    |
      | orderId | orderLineIdThree | fundId | null         | 4      | 'USD'    |

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

  Scenario Outline: get encumbrances transaction
    * def orderId = <orderId>
    * def poLineId = <orderLineId>

    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    Then status 200
    * def transaction = karate.jsonPath(response, "$.transactions[?(@.encumbrance.sourcePoLineId=='"+poLineId+"')]")[0]
    And match transaction.amount == <amount>
    And match transaction.currency == <currency>

    Examples:
      | orderId | orderLineId      | amount | currency |
      | orderId | orderLineIdOne   | 2.0    | 'USD'    |
      | orderId | orderLineIdTwo   | 6.0    | 'USD'    |
      | orderId | orderLineIdThree | 4.0    | 'USD'    |



