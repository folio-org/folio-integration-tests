Feature: budget

  Background:
    * url baseUrl

  Scenario: createBudget
    * def fundId = karate.get('fundId', globalFundId)
    * def fiscalYearId = karate.get('fiscalYearId', globalFiscalYearId)
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
