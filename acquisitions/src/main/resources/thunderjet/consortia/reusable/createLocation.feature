@ignore
Feature: Create location

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create location
    Given path 'locations'
    And request
    """
    {
        "id": "#(id)",
        "name": "#(code)",
        "code": "#(code)",
        "isActive": true,
        "institutionId": "#(institutionId)",
        "campusId": "#(campusId)",
        "libraryId": "#(libraryId)",
        "primaryServicePoint": "#(servicePointId)",
        "servicePointIds": [
            "#(servicePointId)"
        ]
    }
    """
    When method POST
    Then status 201
