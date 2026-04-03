@ignore
Feature: Update pieces statuses in batch
  # parameters: pieceIds, receivingStatus

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Update pieces statuses in batch
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