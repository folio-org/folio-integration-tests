Feature: Create expense class

  Background:
    * url baseUrl

  Scenario: createExpenseClass
    Given path 'finance/expense-classes'
    And request
    """
    {
      "id": "#(id)",
      "code": "#(code)",
      "name": "#(name)",
      "externalAccountNumberExt": "#(externalAccountNumberExt)",
    }
    """
    When method POST
    Then status 201
