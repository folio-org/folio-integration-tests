@parallel=false
Feature: Should open order with polines having the same fund distributions

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2

    * def orderId = callonce uuid3
    * def orderLineIdOne = callonce uuid4
    * def orderLineIdTwo = callonce uuid5

    * def budgetExpenseClassId = callonce uuid6

  Scenario: prepare finances for fund with
    * configure headers = headersAdmin

    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerWithRestrictionsId)' }
    * call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 9999 }

    # prepare expense class
    Given path '/finance-storage/budget-expense-classes'
    And request
      """
        {
          "id": "#(budgetExpenseClassId)",
          "budgetId": "#(budgetId)",
          "expenseClassId": "#(globalPrnExpenseClassId)"
        }
      """
    When method POST
    Then status 201

    # Open order with polines having the same fund distributions
    * configure headers = headersUser
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

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.fundDistribution =
      """
        [{
          "code" : "TST-FND",
          "fundId" : "#(fundId)",
          "distributionType" : "percentage",
          "expenseClassId" : "#(globalPrnExpenseClassId)",
          "value" : 100.0
        }]
      """

    # create first poline
    Given path 'orders/order-lines'
    And request orderLine
    When method POST
    Then status 201

    # create second poline
    Given path 'orders/order-lines'
    And request orderLine
    When method POST
    Then status 201

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
