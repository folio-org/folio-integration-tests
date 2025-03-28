@ignore
Feature: Create pieces batch

  Background:
    * url baseUrl

  Scenario: Create piece
    # Prepare piece collection
    * def samplePiecesIds = []
    * def samplePiecedata = []
    * def populatePiecesData =
      """
      function() {
        for (let i = 0; i < 100; i++) {
          const randomPieceId = uuid();
          samplePiecesIds.push(randomPieceId);
          samplePiecedata.push({ id: randomPieceId, titleId: titleId, poLineId: poLineId, format: 'Physical', locationId: globalLocationsId });
        }
      }
      """
    * eval populatePiecesData()
    * def samplePieceCollection = { pieces: '#(samplePiecedata)', totalRecords: 100 }

    * def pieceCollection = karate.get('pieceCollection', samplePieceCollection)
    Given path 'orders/pieces-batch'
    And request pieceCollection
    When method POST
    Then status 201
