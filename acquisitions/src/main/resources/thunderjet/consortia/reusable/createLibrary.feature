@ignore
Feature: Create library

  Background:
    * url baseUrl

  Scenario: createLibrary
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
