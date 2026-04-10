Feature: Create expense class

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create expense class
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
