@ignore
Feature: Create piece
  # parameters: pieceId, poLineId, titleId, displaySummary?, sequenceNumber?

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create piece
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
