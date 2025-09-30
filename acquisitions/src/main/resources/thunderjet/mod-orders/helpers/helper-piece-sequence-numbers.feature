@ignore
Feature: Helper for "piece-sequence-numbers"

  Background:
    * url baseUrl

  @VerifyTitleNextSequenceNumber #(titleId, nextSequenceNumber)
  Scenario: verifyTitleNextSequenceNumber
    * print 'VerifyTitleNextSequenceNumber:: titleId: ' + titleId + ', nextSequenceNumber: ' + nextSequenceNumber
    Given path 'orders/titles', titleId
    When method GET
    Then status 200
    And match response.nextSequenceNumber == nextSequenceNumber

  @VerifyPieceSequenceNumbersPresent #(poLineId, expectedSequenceNumbers)
  Scenario: verifyPieceSequenceNumbersPresent
    * print 'VerifyPieceSequenceNumbersPresent:: poLineId: ' + poLineId + ', expectedSequenceNumbers: ' + expectedSequenceNumbers
    * def assertPieces =
    """
    function(response) {
      if (response.totalRecords != expectedSequenceNumbers.length) {
        return false;
      }
      for (var i = 0; i < expectedSequenceNumbers.length; i++) {
        var seqNum = expectedSequenceNumbers[i];
        var piece = response.pieces.find(p => p.sequenceNumber === seqNum);
        if (!piece) {
          return false;
        }
      }
      return true;
    }
    """
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    And retry until assertPieces(response)
    When method GET
    Then status 200

  @VerifyPieceSequenceNumbers #(poLineId, expectedPieces)
  Scenario: verifyPieceSequenceNumbers
    * print 'VerifyPieceSequenceNumbers:: poLineId: ' + poLineId + ', expectedPieces: ' + expectedPieces
    * def assertPieces =
    """
    function(response) {
      if (response.totalRecords != Object.keys(expectedPieces).length) {
        return false;
      }
      for (var key in expectedPieces) {
        var piece = response.pieces.find(p => p.displaySummary == key);
        if (!piece || piece.sequenceNumber !== expectedPieces[key]) {
          return false;
        }
      }
      return true;
    }
    """
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    And retry until assertPieces(response)
    When method GET
    Then status 200

  @ChangePieceSequenceNumber #(poLineId, displaySummary, sequenceNumber)
  Scenario: changePieceSequenceNumber
    * print 'ChangePieceSequenceNumber:: poLineId: ' + poLineId + ', displaySummary: ' + displaySummary + ', sequenceNumber: ' + sequenceNumber

    # 1. Get pieces for the poLine
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200

    # 2. Find the piece with the given displaySummary
    * def piece = response.pieces.find(p => p.displaySummary == displaySummary)
    * if (!piece) karate.fail('Piece with displaySummary "' + displaySummary + '" not found for poLineId: ' + poLineId)

    # 3. Update the piece's sequenceNumber
    * set piece.sequenceNumber = sequenceNumber
    Given path 'orders/pieces', piece.id
    And request piece
    When method PUT
    Then status 204