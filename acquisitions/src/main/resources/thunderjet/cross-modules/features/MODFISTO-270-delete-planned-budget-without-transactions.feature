# For MODFISTO-270
Feature: Planned budgets without transactions should be deleted

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables


  Scenario: Planned budgets without transactions should be deleted
    * def currentFundId = call uuid
    * def currentBudgetId = call uuid
    * def plannedBudgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Create funds and current and planned budget
    * def v = call createFund { id: '#(currentFundId)', ledgerId: '#(globalLedgerId)' }
    * def v = call createBudget { id: '#(currentBudgetId)', allocated: 1000, fundId: '#(currentFundId)' }
    * def v = call createBudget  { id: '#(plannedBudgetId)', budgetStatus: 'Planned', allocated: 1000, fundId: '#(currentFundId)', fiscalYearId: '#(globalPlannedFiscalYearId)' }

    # 2. Create order
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create order line
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(currentFundId)', listUnitPrice: 100 }

    # 4. Open order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Verify that planned budget without transaction can be deleted
    Given path 'finance/budgets', plannedBudgetId
    When method DELETE
    Then status 204

    # 6. Verify planned budget was deleted
    Given path 'finance/budgets', plannedBudgetId
    When method GET
    Then status 404

    # 7. Verify that current budget with transaction can't be deleted
    Given path 'finance/budgets', currentBudgetId
    When method DELETE
    Then status 400
    And match $.errors[0].message contains 'Budget related transactions found. Deletion of the budget is forbidden.'
