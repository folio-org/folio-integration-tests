Feature: Open ongoing order

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

  Scenario Outline: prepare finances for fund with <fundId> and budget with <budgetId>
    * def fundId = <fundId>
    * def budgetId = <budgetId>

    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerWithRestrictionsId)'}
    * call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 10000 }

    Examples:
      | fundId | budgetId |
      | fundId | budgetId |

  Scenario: check budget after create
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 10000
    And match budget.expenditures == 0
    And match budget.encumbered == 0
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 0

  Scenario: Create orders

    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'Ongoing',
      "ongoing" : {
        "interval" : 123,
        "isSubscription" : true,
        "renewalDate" : "2021-05-08T00:00:00.000+00:00"
      }
    }
    """
    When method POST
    Then status 201

  Scenario Outline: Create order lines for <orderLineId> and <fundId>
    * def orderId = <orderId>
    * def poLineId = <orderLineId>

    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-physical-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.listUnitPrice = <amount>
    * set orderLine.fundDistribution[0].fundId = <fundId>

    And request orderLine
    When method POST
    Then status 201

    Examples:
      | orderId | orderLineId    | fundId | amount |
      | orderId | orderLineIdOne | fundId | 100    |

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

  Scenario: Check order line status
    # ============= get order to open ===================
    Given path 'orders/order-lines', orderLineIdOne
    When method GET
    Then status 200

    And match response.paymentStatus == 'Ongoing'
    And match response.receiptStatus == 'Ongoing'
