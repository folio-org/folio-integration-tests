@ignore
Feature: Unreceive piece
  # parameters: pieceId

  Background: unreceivePiece
    * url baseUrl

  Scenario: Unreceive piece
    # Get piece 1
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200

    * def piece = $
    # Unreceive it by changing receivingStatus and removing locationId
    * set piece.receivingStatus = 'Expected'
    * remove piece.locationId

    Given path 'orders/pieces', pieceId
    And param deleteHoldings = false
    And request piece
    When method PUT
    Then status 204

    # Wait a bit for the po line to be updated
    * def v = call pause 300