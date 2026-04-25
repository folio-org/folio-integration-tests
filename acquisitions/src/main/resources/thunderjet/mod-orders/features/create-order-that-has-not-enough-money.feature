Feature: Create order that has not enough money
# This will test opening an order when the budget doesn't have enough available money, and when it does.

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


  Scenario: Create order that has not enough money
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineIdOne = call uuid
    * def orderLineIdTwo = call uuid
    * def orderLineIdThree = call uuid

    # 1. Create a fund with allocated and netTransfers values
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)', ledgerId: '#(globalLedgerWithRestrictionsId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 9990, netTransfers: 9 }

    # 2. Check budget after creation
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

    # 3. Create order
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    # 4. Create order lines
    * table poLines
      | id             | listUnitPrice |
      | orderLineIdOne | 4500          |
      | orderLineIdTwo | 5500          |
    * def v = call createOrderLine poLines

    # 5. Try to open the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 422
    And match response.errors[0].code == 'fundCannotBePaid'

    # 6. Check budget after open order failed
    * configure headers = headersAdmin
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

    # 7. Reduce order line two
    * configure headers = headersUser
    Given path 'orders/order-lines', orderLineIdTwo
    When method GET
    Then status 200

    * def polResponse = $
    * set polResponse.cost.listUnitPrice = 5495

    Given path 'orders/order-lines', orderLineIdTwo
    And request polResponse
    When method PUT
    Then status 204

    # 8. Open order after first attempt failed
    * def v = call openOrder { orderId: '#(orderId)' }

    # 9. Check budget after opening order
    * configure headers = headersAdmin
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
