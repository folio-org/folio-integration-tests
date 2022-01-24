Feature: Create piece
  # parameters: pieceId, poLineId, titleId

  Background:
    * url baseUrl

  Scenario: Create piece
    Given path 'orders/pieces'
    And request
    """
    {
      id: "#(pieceId)",
      format: "Physical",
      locationId: "#(globalLocationsId)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId)"
    }
    """
    When method POST
    Then status 201
