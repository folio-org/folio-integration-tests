@ignore
Feature: Update pieces statuses in batch
  # parameters: pieceIds, receivingStatus

  Background:
    * url baseUrl

  Scenario: updatePiecesBatchStatus
    Given path 'orders/pieces-batch/status'
    And request
      """
      {
        "pieceIds": "#(pieceIds)",
        "receivingStatus": "#(receivingStatus)",
      }
      """
    When method PUT
    Then status 204