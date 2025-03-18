Feature: budget

  Background:
    * url baseUrl

  Scenario: createBudget
    * def fundId = karate.get('fundId', '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a696')
    * def fiscalYearId = karate.get('fiscalYearId', 'ac2164c7-ba3d-1bc2-a12c-e35ceccbfaf3')
    * def budgetStatus = karate.get('budgetStatus', 'Active')
    * def statusExpenseClasses = karate.get('statusExpenseClasses', [])

    Given path 'finance/budgets'
    And request
    """
    {
      "id": "#(id)",
      "budgetStatus": "Active",
      "fundId": "#(fundId)",
      "name": "#(id)",
      "fiscalYearId":"#(fiscalYearId)",
      "allocated": #(allocated),
      "allowableEncumbrance": 100.0,
      "allowableExpenditure": 100.0,
      "statusExpenseClasses": "#(statusExpenseClasses)"
    }
    """
    When method POST
    Then status 201