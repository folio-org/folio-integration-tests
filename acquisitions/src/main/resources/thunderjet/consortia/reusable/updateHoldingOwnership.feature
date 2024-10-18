Feature: Update Holding Ownership

  Background:
    * url baseUrl

  Scenario: updateHoldingOwnership
    Given path 'inventory/holdings/update-ownership'
    And request
    """
    {
      toInstanceId: '#(instanceId)',
      holdingsRecordIds: ['#(holdingId)'],
      targetTenantId:  '#(targetTenantId)',
      targetLocationId: '#(targetLocationId)'
    }
    """
    When method POST
    Then status 200
    And assert response.notUpdatedEntities.length == 0
