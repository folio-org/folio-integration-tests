Feature: Claim Pieces
  # parameters: claimingPieceIds, claimingInterval

  Background:
    * url baseUrl

  Scenario: claimPieces
    * def claimingPieceIds = karate.get('claimingPieceIds')
    * def claimingInterval = karate.get('claimingInterval', 1)
    Given path 'pieces/claim'
    And request { claimingPieceIds: '#(claimingPieceIds)', claimingInterval: '#(claimingInterval)' }
    When method POST
    Then status 201