# For MODORDERS-1253
Feature: Change pending distribution with inactive budget

  Background:
    * url baseUrl
    * print karate.info.scenarioName

    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)'  }
    * configure headers = headersAdmin

    * callonce variables

    # Common part for all tests in this feature

    * def fundId1 = call uuid
    * def fundId2 = call uuid
    * def budgetId1 = call uuid
    * def budgetId2 = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    * print '1. Prepare finances, create 2 funds and 2 budgets'
    * def v = call createFund { id: '#(fundId1)' }
    * def v = call createBudget { id: '#(budgetId1)', fundId: '#(fundId1)', allocated: 1000 }
    * def v = call createFund { id: '#(fundId2)' }
    * def v = call createBudget { id: '#(budgetId2)', fundId: '#(fundId2)', allocated: 1000 }

    * print '2. Create order and line'
    * def v = call createOrder { id: '#(orderId)' }
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId1)' }

    * print '3. Open the order'
    * def v = call openOrder { orderId: '#(orderId)' }

    * print '4. Unopen the order'
    * def v = call unopenOrder { orderId: '#(orderId)' }

    * print '5. Make budget 1 inactive'
    * configure headers = headersAdmin
    Given path 'finance/budgets', budgetId1
    When method GET
    Then status 200
    * def budget = $
    * set budget.budgetStatus = 'Inactive'
    Given path 'finance/budgets', budgetId1
    And request budget
    When method PUT
    Then status 204


  @Positive
  Scenario: Change the fund distribution to use fund 2
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * set poLine.fundDistribution[0].fundId = fundId2
    * remove poLine.fundDistribution[0].encumbrance

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204


  @Positive
  Scenario: Remove the fund distribution
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200

    * def poLine = $
    * remove poLine.fundDistribution

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204


  @Positive
  Scenario: Delete the po line
    Given path 'orders/order-lines', poLineId
    When method DELETE
    Then status 204
