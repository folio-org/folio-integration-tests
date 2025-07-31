@ignore
Feature: Create piece with holding id or location id
  # Parameters: id, poLineId, titleId, holdingId?, locationId?, useLocationId?, receivingTenantId?, format?, createItem?

  Background:
    * url baseUrl

  Scenario: createPieceWithHoldingOrLocation
    * def id = karate.get('id')
    * def poLineId = karate.get('poLineId')
    * def titleId = karate.get('titleId')
    * def holdingId = karate.get('holdingId', globalHoldingId1)
    * def locationId = karate.get('locationId', null)
    * def useLocationId = karate.get('useLocationId', false)
    * def receivingTenantId = karate.get('receivingTenantId', null)
    * def format = karate.get('format', "Physical")
    * def createItem = karate.get('createItem', false)

    * def piecePayload =
    """
    {
      id: "#(id)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId)",
      receivingTenantId: "#(receivingTenantId)",
      format: "#(format)"
    }
    """

    # Add either holdingId or locationId based on useLocationId flag
    * if(useLocationId)  piecePayload.locationId = locationId
    * if(!useLocationId) piecePayload.holdingId = holdingId

    Given path 'orders/pieces'
    And param createItem = createItem
    And request piecePayload
    When method POST
    Then status 201