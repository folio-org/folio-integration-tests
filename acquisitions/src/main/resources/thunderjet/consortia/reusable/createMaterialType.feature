@ignore
Feature: Create material type

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create material type
    Given path 'material-types'
    And request
    """
    {
      "id": "#(id)",
      "name": "#(name)"
    }
    """
    When method POST
    Then status 201
