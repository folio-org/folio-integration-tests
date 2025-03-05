Feature: Create holding

  Background:
    * url baseUrl

  Scenario: createHolding
    Given path 'holdings-storage/holdings'
    And request
      """
      {
        id: "#(id)",
        instanceId: "#(instanceId)",
        permanentLocationId: "#(locationId)",
        sourceId : "#(sourceId)"
      }
      """
    When method POST
    Then status 201
