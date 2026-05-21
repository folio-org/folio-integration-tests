@ignore
Feature: Create campus

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create campus
    Given path 'location-units/campuses'
    And request
    """
    {
        "id": "#(id)",
        "institutionId": "#(institutionId)",
        "name": "#(name)",
        "code": "#(code)"
    }
    """
    When method POST
    Then status 201
