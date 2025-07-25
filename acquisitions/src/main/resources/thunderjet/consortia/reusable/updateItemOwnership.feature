@ignore
Feature: Update Item Ownership

  Background:
    * url baseUrl

  Scenario: updateItemOwnership
    Given path 'inventory/items/update-ownership'
    And request
    """
    {
      toHoldingsRecordId: '#(holdingId)',
      itemIds: ['#(itemId)'],
      targetTenantId:  '#(targetTenantId)'
    }
    """
    When method POST
    Then status 200
    And assert response.notUpdatedEntities.length == 0
