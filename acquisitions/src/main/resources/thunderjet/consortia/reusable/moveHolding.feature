Feature: Move holding

  Background:
    * url baseUrl

  Scenario: Move holding
    Given path 'inventory/holdings/move'
    And request
    """
    {
      toInstanceId: "#(instanceId)",
      holdingsRecordIds: ["#(holdingId)"]
    }
    """
    When method POST
    Then status 200
    And assert response.nonUpdatedIds.length == 0
