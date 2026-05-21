Feature: Close order and release encumbrances

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


  Scenario: Close order and release encumbrances
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def orderLineIdOne = call uuid
    * def orderLineIdTwo = call uuid

    # 1. Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerWithRestrictionsId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'fundId': '#(fundId)', 'allocated': 10000 }

    # 2. Check budget after creation
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

    # 3. Create order
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    # 4. Create order lines
    * table poLines
    | poLineId       | listUnitPrice |
    | orderLineIdOne | 4500          |
    | orderLineIdTwo | 5500          |
    * def v = call createOrderLine poLines

    # 5. Open order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 6. Check budget after opening order
    * configure headers = headersAdmin
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 0
    And match budget.expenditures == 0
    And match budget.encumbered == 10000
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 10000

    # 7. Close order and release encumbrances
    * configure headers = headersUser
    * def v = call closeOrder { orderId: '#(orderId)' }

    # 8. Check budget after closing order
    * configure headers = headersAdmin
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
