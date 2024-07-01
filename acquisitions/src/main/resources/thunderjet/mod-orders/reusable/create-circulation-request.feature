Feature: Reusable function to init circulation request

  Background:
    * url baseUrl

  @CreateCirculationRequest
  Scenario: Create circulation request
    * def randomUuid = call uuid
    * def id = karate.get('id', randomUuid)
    * def itemId = karate.get('itemId', randomUuid)
    * def userId = karate.get('userId', randomUuid)
    * def holdingId = karate.get('holdingId', globalHoldingId1)
    * def instanceId = karate.get('instanceId', globalInstanceId1)

    Given path 'circulation/requests'
    And request
      """
      {
        "id": "#(id)",
        "requestLevel": "Item",
        "requestType": "Hold",
        "requestDate": "2023-03-23T11:04:25.000+00:00",
        "holdingsRecordId": "#(holdingId)",
        "requesterId": "#(userId)",
        "instanceId": "#(instanceId)",
        "itemId": "#(itemId)",
        "fulfillmentPreference": "Delivery"
      }
      """
    When method POST
    Then status 201