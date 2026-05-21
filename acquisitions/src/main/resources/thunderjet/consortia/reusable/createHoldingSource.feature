@ignore
Feature: Create holding source

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create holding source
    Given path 'holdings-sources'
    And request
    """
    {
      "id": "#(id)",
      "name": "#(name)"
    }
    """
    When method POST
    Then status 201
