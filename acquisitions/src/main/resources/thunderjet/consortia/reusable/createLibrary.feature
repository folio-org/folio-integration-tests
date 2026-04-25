@ignore
Feature: Create library

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create library
    Given path 'location-units/libraries'
    And request
    """
    {
        "id": "#(id)",
        "campusId": "#(campusId)",
        "name": "#(name)",
        "code": "#(code)"
    }
    """
    When method POST
    Then status 201
