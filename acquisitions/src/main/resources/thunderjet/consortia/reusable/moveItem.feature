@ignore
Feature: Move item

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Move item
    Given path 'inventory/items/move'
    And request
    """
    {
      toHoldingsRecordId: "#(holdingId)",
      itemIds: ["#(itemId)"]
    }
    """
    When method POST
    Then status 200
    And assert response.nonUpdatedIds.length == 0
