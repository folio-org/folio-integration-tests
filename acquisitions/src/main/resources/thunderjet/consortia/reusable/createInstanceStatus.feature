@ignore
Feature: Create instance status

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create instance status
    Given path 'instance-statuses'
    And request
    """
    {
      "id": "#(id)",
      "code": "#(code)",
      "name": "#(code)",
      "source": "apiTests"
    }
    """
    When method POST
    Then status 201
