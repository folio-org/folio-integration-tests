@ignore
Feature: Create institution

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create institution
    Given path 'location-units/institutions'
    And request
    """
    {
        "id": "#(id)",
        "name": "#(name)",
        "code": "#(code)"
    }
    """
    When method POST
    Then status 201
