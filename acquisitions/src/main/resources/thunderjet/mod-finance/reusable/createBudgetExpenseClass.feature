Feature: Create Budget Expense Class

  Background:
    * url baseUrl

  Scenario: Add expense class to budget
    * def newGeneratedId = call uuid
    * def id = karate.get('id', newGeneratedId)

    Given path '/finance/budget-expense-classes'
    And request
    """
      {
        "id": "#(id)",
        "budgetId": "#(budgetId)",
        "expenseClassId": "#(expenseClassId)"
      }
    """
    When method POST
    Then assert responseStatus == 201