Feature: Create piece with holding id
  # Parameters: pieceId, poLineId, titleId, holdingId, format

  Background:
    * url baseUrl

  Scenario: Create piece
    * def id = karate.get('id')
    * def poLineId = karate.get('poLineId')
    * def titleId = karate.get('titleId')
    * def holdingId = karate.get('holdingId', globalHoldingId1)
    * def format = karate.get('format', "Physical")
    Given path 'orders/pieces'
    And request
    """
    {
      id: "#(id)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId)",
      holdingId: "#(holdingId)",
      format: "#(format)"
    }
    """
    When method POST
    Then status 201
