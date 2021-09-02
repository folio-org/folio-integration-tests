@parallel=false
Feature: Create order that has not enough money
# This will test opening an order when the budget doesn't have enough available money, and when it does.

  Background:
    * url baseUrl
    # uncomment below line for development
    #* callonce dev {tenant: 'test_orders'}
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


  Scenario: Create a fund with allocated and netTransfers values
    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerWithRestrictionsId)'}

    Given path 'finance/budgets'
    And request
    """
    {
      "id": "#(budgetId)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(id)",
      "fiscalYearId":"#(globalFiscalYearId)",
      "allocated": 9990,
      "allowableEncumbrance": 100.0,
      "allowableExpenditure": 100.0,
      netTransfers: 9
    }
    """
    When method POST
    Then status 201

  Scenario: Check budget after create
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 9999
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
    * set orderLine.fundDistribution[0].fundId = <fundId>

    And request orderLine
    When method POST
    Then status 201

    Examples:
      | orderId | orderLineId    | fundId | amount |
      | orderId | orderLineIdOne | fundId | 4500   |
      | orderId | orderLineIdTwo | fundId | 5500   |

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
    Then status 422
    And match response.errors[0].code == 'fundCannotBePaid'

  Scenario: Check budget after open order failed
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 9999
    And match budget.expenditures == 0
    And match budget.encumbered == 0
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 0

  Scenario: Reduce order line two
    * def poLineId = orderLineIdTwo

    # ============= get order line to modify ===================
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    # ============= modify order line ===================
    * def polResponse = $
    * set polResponse.cost.listUnitPrice = 5495

    Given path 'orders/order-lines', poLineId
    And request polResponse
    When method PUT
    Then status 204

  Scenario: Open order after first attempt failed
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

  Scenario: Check budget after opening order
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 4
    And match budget.expenditures == 0
    And match budget.encumbered == 9995
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 9995
