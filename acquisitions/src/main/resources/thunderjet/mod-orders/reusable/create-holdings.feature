Feature: Create a holdings

  Background:
    * url baseUrl

  Scenario: Create holdings
    Given path 'holdings-storage/holdings'
    And request
    """
    {
      id: '#(holdingId)',
      instanceId: '#(instanceId)',
      permanentLocationId: '#(locationId)'
    }
    """
    When method POST
    Then status 201
