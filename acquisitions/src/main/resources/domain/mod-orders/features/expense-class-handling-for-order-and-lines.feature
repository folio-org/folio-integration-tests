Feature: Handling of expense classes for order and order lines

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

    * def fundIdForActiveExpenseClass = callonce uuid1
    * def fundIdForInactiveExpenseClass = callonce uuid2

    * def budgetIdWithActiveExpenseClass = callonce uuid3
    * def budgetIdWithInactiveExpenseClass = callonce uuid4

    * def orderWithActiveExpenseClass = callonce uuid5
    * def orderWithInactiveExpenseClass = callonce uuid6
    * def orderLineWithActiveExpenseClass = callonce uuid7
    * def orderLineWithInactiveExpenseClass = callonce uuid8

  Scenario Outline: prepare finances for fund with <fundId> and budget with <budgetId>
    * def fundId = <fundId>
    * def budgetId = <budgetId>

    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 99999999}

    Examples:
      | fundId                        | budgetId                         |
      | fundIdForActiveExpenseClass   | budgetIdWithActiveExpenseClass   |
      | fundIdForInactiveExpenseClass | budgetIdWithInactiveExpenseClass |

  Scenario Outline: create budgetExpense class relation with expenseClassId <expenseClassId> and budget <budgetId>
    * def budgetId = <budgetId>
    * def expenseClassId = <expenseClassId>

    Given path 'finance-storage/budget-expense-classes'
    And request
    """
    {
      "budgetId": "#(budgetId)",
      "expenseClassId": "#(expenseClassId)",
      "status": <status>
    }
    """
    When method POST
    Then status 201

    Examples:
      | budgetId                         | expenseClassId           | status     |
      | budgetIdWithActiveExpenseClass   | globalElecExpenseClassId | "Active"   |
      | budgetIdWithActiveExpenseClass   | globalPrnExpenseClassId  | "Active"   |
      | budgetIdWithInactiveExpenseClass | globalElecExpenseClassId | "Active"   |
      | budgetIdWithInactiveExpenseClass | globalPrnExpenseClassId  | "Inactive" |

  Scenario Outline: Create orders for <orderId>

    * def orderId = <orderId>

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

    Examples:
      | orderId                       |
      | orderWithActiveExpenseClass   |
      | orderWithInactiveExpenseClass |


  Scenario Outline: Create order lines for <orderLineId> and <fundId>
    * def orderId = <orderId>
    * def poLineId = <orderLineId>

    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/minimal-order-line.json')
    * set orderLine.id = poLineId
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.fundDistribution[0].fundId = <fundId>
    * set orderLine.fundDistribution[0].expenseClassId = globalPrnExpenseClassId

    And request orderLine
    When method POST
    Then status 201

    Examples:
      | orderId                       | orderLineId                       | fundId                        |
      | orderWithActiveExpenseClass   | orderLineWithActiveExpenseClass   | fundIdForActiveExpenseClass   |
      | orderWithInactiveExpenseClass | orderLineWithInactiveExpenseClass | fundIdForInactiveExpenseClass |

  Scenario: Open order with active Expense class
    # ============= get order to open ===================
    Given path 'orders/composite-orders', orderWithActiveExpenseClass
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    # ============= update order to open ===================
    Given path 'orders/composite-orders', orderWithActiveExpenseClass
    And request orderResponse
    When method PUT
    Then status 204

  Scenario: Open order with inactive Expense class
    # ============= get order to open ===================
    Given path 'orders/composite-orders', orderWithInactiveExpenseClass
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    # ============= update order to open ===================
    Given path 'orders/composite-orders', orderWithInactiveExpenseClass
    And request orderResponse
    When method PUT
    Then status 400
    * match response.errors[0].code == 'inactiveExpenseClass'

  Scenario: Update orderLine from Active to Inactive expense class
    # ============= get order line to update ===================
    Given path 'orders/order-lines', orderLineWithActiveExpenseClass
    When method GET
    Then status 200

    * def orderLine = $
    * set orderLine.fundDistribution[0].fundId = fundIdForInactiveExpenseClass
    * set orderLine.fundDistribution[0].expenseClassId = globalPrnExpenseClassId

    # ============= update order line with updated fundId and expenseClassId ===================
    Given path 'orders/order-lines', orderLineWithActiveExpenseClass
    And request orderLine
    When method PUT
    Then status 400
    And match response.errors[0].code == 'inactiveExpenseClass'

  Scenario: Update orderLine from Active to another Active expense class
    # ============= get order line to update ===================
    Given path 'orders/order-lines', orderLineWithActiveExpenseClass
    When method GET
    Then status 200

    * def orderLine = $
    * set orderLine.fundDistribution[0].fundId = fundIdForActiveExpenseClass
    * set orderLine.fundDistribution[0].expenseClassId = globalPrnExpenseClassId

    # ============= update order line with updated fundId and expenseClassId ===================
    Given path 'orders/order-lines', orderLineWithActiveExpenseClass
    And request orderLine
    When method PUT
    Then status 204
