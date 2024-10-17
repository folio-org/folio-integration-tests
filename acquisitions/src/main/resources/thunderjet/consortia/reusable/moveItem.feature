Feature: Move item

  Background:
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
