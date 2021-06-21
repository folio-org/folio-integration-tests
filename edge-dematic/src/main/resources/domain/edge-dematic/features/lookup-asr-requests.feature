Feature: test asrService/asr/lookupAsrRequests request

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }

    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

    * callonce variables
    * def itemId = callonce uuid1
    * def itemBarcode = callonce barcode1
    * def requestId = callonce uuid2
    * def currentDate = call isoDate

  Scenario: create remote storage configuration to location mapping
    Given path 'remote-storage/mappings'
    And headers headers
    And request
    """
    {
      "folioLocationId": "53cf956f-c1df-410b-8bea-27f712cca7c0",
      "configurationId": "de17bad7-2a30-4f1c-bee5-f653ded15629"
    }
    """
    When method POST
    Then status 201

  Scenario: create user
    Given path 'users'
    And headers headers
    And request
    """
    {
      "active" : true,
      "personal" : {
        "preferredContactTypeId" : "002",
        "lastName" : "User1",
        "firstName" : "Sample",
        "email" : "sample.user1@folio.org"
      },
      "username" : "sample_user1",
      "patronGroup" : "503a81cd-6c26-400f-b620-14c08943697c",
      "expirationDate" : "2022-03-15T00:00:00.000Z",
      "id" : "#(user1Id)",
      "barcode" : "#(user1Barcode)",
      "departments":[]
    }
    """
    When method POST
    Then status 201

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
      "requestDate" : "#(currentDate)",
      "id" : "#(requestId)"
    }
    """
    When method POST
    Then status 201
    
    * callonce sleep 5

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

  Scenario: close request
    Given path 'circulation/requests', requestId
    And headers headers
    When method GET
    Then status 200
    * def requestJson = $

    * set requestJson.status = "Closed - Cancelled"
    * set requestJson.cancelledByUserId = user1Id
    * set requestJson.cancellationReasonId = cancellationReasonId
    * set requestJson.cancelledDate = currentDate
    Given path 'circulation/requests', requestId
    And headers headers
    And request requestJson
    When method PUT
    Then status 204

  Scenario: delete item
    Given path 'inventory/items', itemId
    And headers headers
    When method DELETE
    Then status 204

  Scenario: delete user
    Given path 'users', user1Id
    And headers headers
    When method DELETE
    Then status 204