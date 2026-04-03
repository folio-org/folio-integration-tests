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


  Scenario: Should open order with polines having the same fund distributions
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineIdOne = call uuid
    * def orderLineIdTwo = call uuid
    * def budgetExpenseClassId = call uuid

    # prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)', ledgerId: '#(globalLedgerWithRestrictionsId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 9999 }

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
    * def v = call createOrder { id: '#(orderId)' }

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

    # open order
    * def v = call openOrder { orderId: '#(orderId)' }
