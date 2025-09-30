@ignore
Feature: Create piece
  # parameters: pieceId, poLineId, titleId, displaySummary?, sequenceNumber?

  Background:
    * url baseUrl

  Scenario: createPiece
    * def pieceId = karate.get('pieceId', null)
    * def displaySummary = karate.get('displaySummary', null)
    * def sequenceNumber = karate.get('sequenceNumber', null)

    Given path 'orders/pieces'
    And request
    """
    {
      id: "#(pieceId)",
      format: "Physical",
      locationId: "#(globalLocationsId)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId)",
      displaySummary: "#(displaySummary)",
      sequenceNumber: #(sequenceNumber)
    }
    """
    When method POST
    Then status 201
