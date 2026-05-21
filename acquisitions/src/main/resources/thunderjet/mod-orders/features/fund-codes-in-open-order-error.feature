# created for MODORDERS-652
Feature: Fund codes in open order error

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


  Scenario: Fund codes in open order error
    * def fundId1 = call uuid
    * def fundId2 = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    * def fundCode = 'RESTRICTED-FUND'

    # 1. Create funds and budgets
    * configure headers = headersAdmin
    # avoiding shared scope with def to avoid defining a fundCode variable and using it in the next call to createFund
    * def v = call createFund { id: '#(fundId1)', ledgerId: '#(globalLedgerWithRestrictionsId)', code: '#(fundCode)' }
    * def v = call createBudget { id: '#(budgetId1)', fundId: '#(fundId1)', allocated: 100 }
    * def v = call createFund { id: '#(fundId2)', ledgerId: '#(globalLedgerId)' }
    * def v = call createBudget { id: '#(budgetId2)', fundId: '#(fundId2)', allocated: 100 }

    # 2. Create composite order
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create order line
    * table fundDistribution
      | fundId  | code        | distributionType | value |
      | fundId1 | fundCode    | 'percentage'     | 50.0  |
      | fundId2 | fundId2     | 'percentage'     | 50.0  |
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 300, fundDistribution: '#(fundDistribution)' }

    # 4. Try to open order, check error code
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 422
    And match $.errors[0].code == 'fundCannotBePaid'
    And match $.errors[0].parameters[0].value == '[' + fundCode + ']'
