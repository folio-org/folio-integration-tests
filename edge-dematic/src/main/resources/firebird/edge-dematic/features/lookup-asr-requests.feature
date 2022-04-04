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

    Given path '/groups'
    And headers headers
    And request
    """
      {
         "group": "#(dematicGroupName)",
         "desc": "basic dematic test group",
         "expirationOffsetInDays": 365,
         "id": "#(dematicGroupId)"
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
      "patronGroup" : "#(dematicGroupId)",
      "expirationDate" : "2030-03-15T00:00:00.000Z",
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
    Given path '/request-policy-storage/request-policies'
    And headers headers
    And request
    """
    {
        "id": "#(dematicPageRequestPolicyId)",
        "name": "#(dematicPageRequestPolicyName )",
        "description" : "description",
        "requestTypes": [
            "Page"
       ]
    }
    """
    When method POST
    Then status 201

    * def dematicRules = '\n\ng ' + dematicGroupId + ' : l d9cd0bed-1b49-4b5e-a7bd-064b8d177231 r ' + dematicPageRequestPolicyId + ' n 122b3d2b-4788-4f1e-9117-56daa91cb75c o cd3f6cac-fa17-4079-9fae-2fb28e521412 i ed892c0e-52e0-4cd9-8133-c0ef07b4a709'

    Given path '/circulation/rules'
    And headers headers
    When method GET
    Then status 200

    * def body = $
    * def initialCirculationRules = body.rulesAsText
    * def newRules = body.rulesAsText + dematicRules
    * set body.rulesAsText = newRules

    Given path '/circulation/rules'
    And headers headers
    And request body
    When method PUT
    Then status 204

    * call sleep 5

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
      "instanceId" : "#(instanceId)",
      "requestLevel" : "Item",
      "holdingsRecordId" : "#(holdingsRecordId)",
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

    * set body.rulesAsText = initialCirculationRules

    Given path '/circulation/rules'
    And headers headers
    And request body
    When method PUT
    Then status 204

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
    And match $.asrRequests == null

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

   Scenario: clean test group

     Given path '/groups/', dematicGroupId
     And headers headers
     When method DELETE
     Then status 204

   Scenario: clean test policy

     Given path '/request-policy-storage/request-policies/', dematicPageRequestPolicyId
     And headers headers
     When method DELETE
     Then status 204
