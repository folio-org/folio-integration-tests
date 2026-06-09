@ignore
Feature: Unreceive piece like UI
  # parameters: pieceId, poLineId

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Unreceive piece like UI (using the /receive endpoint)
    Given path 'orders/receive'
    And request
    """
    {
      "toBeReceived": [
        {
          "poLineId": "#(poLineId)",
          "received": 1,
          "receivedItems": [
            {
              "displayOnHolding": false,
              "displayToPublic": false,
              "itemStatus": "On order",
              "pieceId": "#(pieceId)",
              "sequenceNumber": 1
            }
          ]
        }
      ],
      "totalRecords": 1
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].receivingItemResults[0].processingStatus.type == 'success'
