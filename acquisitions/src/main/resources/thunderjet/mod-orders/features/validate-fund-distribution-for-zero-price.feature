# For MODORDERS-715
Feature: Validate fund distribution for zero price

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


  @Positive
  Scenario: Validate fund distribution for zero price
    * def fundId1 = call uuid
    * def budgetId1 = call uuid
    * def fundId2 = call uuid
    * def budgetId2 = call uuid
    * def orderId = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid

    * print '1. Prepare finances'
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId1)' }
    * def v = call createBudget { id: '#(budgetId1)', fundId: '#(fundId1)', allocated: 1000 }
    * def v = call createFund { id: '#(fundId2)' }
    * def v = call createBudget { id: '#(budgetId2)', fundId: '#(fundId2)', allocated: 1000 }

    * print '2. Create an order'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    * print '3. Create an order line with a fund distribution using amounts'
    * table fundDistribution
      | fundId  | code    | distributionType | value |
      | fundId1 | fundId1 | 'amount'         | 0.0   |
      | fundId2 | fundId2 | 'amount'         | 0.0   |
    * def v = call createOrderLine { id: '#(poLineId1)', orderId: '#(orderId)', listUnitPrice: 0.0, fundDistribution: '#(fundDistribution)' }

    * print '4. Create an order line with a fund distribution using percentages'
    * table fundDistribution
      | fundId  | code    | distributionType | value |
      | fundId1 | fundId1 | 'percentage'     | 50.0  |
      | fundId2 | fundId2 | 'percentage'     | 50.0  |
    * def v = call createOrderLine { id: '#(poLineId2)', orderId: '#(orderId)', listUnitPrice: 0.0, fundDistribution: '#(fundDistribution)' }

    * print '5. Open the order'
    * def v = call openOrder { orderId: '#(orderId)' }

