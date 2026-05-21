@ignore
Feature: Create service point

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create service point
    Given path 'service-points'
    And request
    """
    {
        "id": "#(id)",
        "name": "#(name)",
        "code": "#(code)",
        "discoveryDisplayName": "#(discoveryDisplayName)"
    }
    """
    When method POST
    Then status 201
