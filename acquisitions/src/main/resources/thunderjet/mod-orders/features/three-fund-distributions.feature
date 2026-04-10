# For MODORDERS-646
Feature: Three fund distributions

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


  Scenario: Three fund distributions
    * def fundId1 = call uuid
    * def fundId2 = call uuid
    * def fundId3 = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def budgetId3 = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Create funds and budgets
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId1)', ledgerId: '#(globalLedgerId)' }
    * def v = call createFund { id: '#(fundId2)', ledgerId: '#(globalLedgerId)' }
    * def v = call createFund { id: '#(fundId3)', ledgerId: '#(globalLedgerId)' }
    * def v = call createBudget { id: '#(budgetId1)', fundId: '#(fundId1)', allocated: 1000 }
    * def v = call createBudget { id: '#(budgetId2)', fundId: '#(fundId2)', allocated: 1000 }
    * def v = call createBudget { id: '#(budgetId3)', fundId: '#(fundId3)', allocated: 1000 }

    # 2. Create a composite order
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create an order line
    * table fundDistribution
      | fundId  | code    | distributionType | value |
      | fundId1 | fundId1 | 'amount'         | 30.0  |
      | fundId2 | fundId2 | 'amount'         | 30.0  |
      | fundId3 | fundId3 | 'amount'         | 30.0  |
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 90, fundDistribution: '#(fundDistribution)' }

    # 4. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }
