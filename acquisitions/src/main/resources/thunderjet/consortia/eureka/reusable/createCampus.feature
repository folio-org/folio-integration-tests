Feature: Create campus

  Background:
    * url baseUrl

  Scenario: createCampus
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
