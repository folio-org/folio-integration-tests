# For MODFIN-405
Feature: Create inactive budget

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def fundId = call uuid
    * def budgetId = call uuid

    # Prepare finance data, for all tests
    * def v = call createFund { id: '#(fundId)' }


  @Positive
  Scenario: Create an inactive budget without any allocation
    * def v = call createBudget { id: '#(budgetId)', allocated: 0, fundId: '#(fundId)', budgetStatus: 'Inactive' }

    Given path '/finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.budgetStatus == 'Inactive'
    And match $.allocated == 0


  @Positive
  Scenario: Create an inactive budget with an allocation
    * def v = call createBudget { id: '#(budgetId)', allocated: 100, fundId: '#(fundId)', budgetStatus: 'Inactive' }

    Given path '/finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.budgetStatus == 'Inactive'
    And match $.allocated == 100


  @Negative
  Scenario: Try to create a budget with negative allowableEncumbrance or allowableExpenditure
    Given path 'finance/budgets'
    And request
      """
      {
        "id": "#(budgetId)",
        "budgetStatus": "Active",
        "fundId": "#(fundId)",
        "name": "#(budgetId)",
        "fiscalYearId": "#(globalFiscalYearId)",
        "allocated": 0,
        "allowableEncumbrance": -1.0,
        "allowableExpenditure": 100.0
      }
      """
    When method POST
    Then status 422

    Given path 'finance/budgets'
    And request
      """
      {
        "id": "#(budgetId)",
        "budgetStatus": "Active",
        "fundId": "#(fundId)",
        "name": "#(budgetId)",
        "fiscalYearId": globalFiscalYearId,
        "allocated": 0,
        "allowableEncumbrance": 100.0,
        "allowableExpenditure": -1.0
      }
      """
    When method POST
    Then status 422


  @Negative
  Scenario: Try to create a budget with negative allocation
    Given path 'finance/budgets'
    And request
      """
      {
        "id": "#(budgetId)",
        "budgetStatus": "Active",
        "fundId": "#(fundId)",
        "name": "#(budgetId)",
        "fiscalYearId": "#(globalFiscalYearId)",
        "allocated": -10
      }
      """
    When method POST
    Then status 422
