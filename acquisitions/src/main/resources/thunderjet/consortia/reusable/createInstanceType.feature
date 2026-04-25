@ignore
Feature: Create instance type

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create instance type
    Given path 'instance-types'
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
