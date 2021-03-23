Feature: test asrService/asr/lookupAsrRequests request

  Background:
    * url baseUrl
    * callonce login admin

    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

    * callonce variables
    * def itemId = callonce uuid1
    * def itemBarcode = callonce barcode1

  Scenario: lookup new asr requests to clean up retrieval queue
    Given url edgeUrl
    And path 'asrService/asr/lookupAsrRequests', storageId
    And param apikey = apikey
    When method GET
    Then status 200

  Scenario: create item
    Given path 'inventory/items'
    And headers headers
    And request
    """
    {
      "circulationNotes" : [ {
        "noteType" : "Check in", "note":"Sample note"
      } ],
      "permanentLoanType" : {
        "id" : "2b94c631-fca9-4892-a730-03ee529ffe27"
      },
      "materialType" : {
        "id" : "1a54b431-2e4f-452d-9cae-9cee66c9a892"
      },
      "barcode" : "#(itemBarcode)",
      "holdingsRecordId" : "#(holdingsRecordId)",
      "temporaryLocation" : { "id" : "#(remoteLocationId)" },
      "status" : {
        "name" : "Available"
      },
      "id" : "#(itemId)"
    }
    """
    When method POST
    Then status 201

  Scenario: create page request
    * def requestId = call uuid2
    * def requestDate = call isoDate
    Given path 'circulation/requests'
    And headers headers
    And request
    """
    {
      "requestType" : "Page",
      "fulfilmentPreference" : "Hold Shelf",
      "item" : {
        "barcode" : "#(itemBarcode)"
      },
      "itemId" : "#(itemId)",
      "requester" : {
        "barcode" : "#(user1Barcode)"
      },
      "requesterId" : "#(user1Id)",
      "pickupServicePointId" : "#(servicePointId)",
      "requestDate" : "#(requestDate)",
      "id" : "#(requestId)"
    }
    """
    When method POST
    Then status 201

  Scenario: lookup new asr requests
    Given url edgeUrl
    And path 'asrService/asr/lookupAsrRequests', storageId
    And param apikey = apikey
    When method GET
    Then status 200
    * def resp = $
    And match resp count(/asrRequests//asrRequest) == 1
    And match resp //asrRequest/itemBarcode == itemBarcode

  Scenario: subsequent request should respond with empty result
    Given url edgeUrl
    And path 'asrService/asr/lookupAsrRequests', storageId
    And param apikey = apikey
    When method GET
    Then status 200
    And match $ == '<asrRequests/>'