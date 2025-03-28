Feature: Create institution

  Background:
    * url baseUrl

  Scenario: createInstitution
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
