@ignore
Feature: Create service point

  Background:
    * url baseUrl

  Scenario: createServicePoint
    Given path 'service-points'
    And request
    """
    {
        "id": "#(id)",
        "name": "#(name)",
        "code": "#(code)",
        "discoveryDisplayName": "#(discoveryDisplayName)",
        "pickupLocation": true,
        "holdShelfExpiryPeriod": {
            "duration": 3,
            "intervalId": "Weeks"
        }
    }
    """
    When method POST
    Then status 201
