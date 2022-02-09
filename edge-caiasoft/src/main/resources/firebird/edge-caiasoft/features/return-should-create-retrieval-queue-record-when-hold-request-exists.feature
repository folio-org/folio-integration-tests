Feature: test CaiaSoft return: should create retrieval queue record if hold request exists

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * callonce variables
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

    * def currentDate = call isoDate
    * def checkoutId = call uuid

  # prepare test data
  Scenario: create remote storage configuration
    Given path '/remote-storage/configurations'
    And headers headers
    And request
    """
    {
        "id": '#(remoteStorageId)',
        "name": "RSTest",
        "providerName": "CAIA_SOFT",
        "url": "http://endpoint",
        "accessionDelay": 2,
        "accessionTimeUnit": "minutes",
        "accessionWorkflowDetails": "Change permanent location",
        "returningWorkflowDetails": "Scanned to CaiaSoft"
    }
    """
    When method POST
    Then status 201

  Scenario: create mapping
    Given path 'remote-storage/mappings'
    And headers headers
    And request
    """
    {
      "folioLocationId": '#(remoteFolioLocationId)',
      "configurationId": '#(remoteStorageId)'
    }
    """
    When method POST
    Then status 201

  Scenario: create instance
    Given path '/inventory/instances'
    And headers headers
    And request
    """
    {
        "id": '#(instanceId)',
        "source": "FOLIO",
        "title": "Interesting Times",
        "alternativeTitles": [],
        "editions": [],
        "series": [],
        "instanceTypeId": '#(instanceTypeId)'
    }
    """
    When method POST
    Then status 201

  Scenario: create holding
    Given path 'holdings-storage/holdings'
    And headers headers
    And request
    """
    {
        "id": '#(holdingsRecordId)',
        "formerIds": [],
        "instanceId": '#(instanceId)',
        "permanentLocationId": '#(remoteFolioLocationId)',
        "effectiveLocationId": '#(remoteFolioLocationId)',
        "electronicAccess": [],
        "callNumber": "PR6056.I4588 B749 2016"
    }
    """
    When method POST
    Then status 201

  Scenario: create item
    Given path 'inventory/items'
    And headers headers
    And request
    """
    {
        "id": '#(itemId)',
        "title": "A semantic web primer",
        "status": {
            "name": "Available",
            "date": "2021-05-12T03:22:24.508+00:00"
        },
        "callNumber": "TK5105.88815 . A58 2004 FT MEADE",
        "contributorNames": [
            {
                "name": "Antoniou, Grigoris"
            },
            {
                "name": "Van Harmelen, Frank"
            }
        ],
        "formerIds": [],
        "discoverySuppress": null,
        "holdingsRecordId": '#(holdingsRecordId)',
        "barcode": '#(itemBarcode)',
        "itemLevelCallNumber": "TK5105.88815 . A58 2004 FT MEADE",
        "materialType": {
            "id": "1a54b431-2e4f-452d-9cae-9cee66c9a892"
        },
          "permanentLoanType": {
            "id": "2b94c631-fca9-4892-a730-03ee529ffe27"
        },
        "permanentLocation": {
            "id": "#(remoteFolioLocationId)"
        }
    }
    """
    When method POST
    Then status 201

  Scenario: create sample user
    Given path 'users'
    And headers headers
    And request
    """
    {
      "active" : true,
      "personal" : {
        "preferredContactTypeId" : "002",
        "lastName" : "User",
        "firstName" : "Sample",
        "email" : "sample.user@folio.org"
      },
      "username" : "sample_user",
      "patronGroup" : "503a81cd-6c26-400f-b620-14c08943697c",
      "expirationDate" : "2022-03-15T00:00:00.000Z",
      "id" : '#(user1Id)',
      "barcode" : '#(user1Barcode)',
      "departments":[]
    }
    """
    When method POST
    Then status 201

  Scenario: create another user
    Given path 'users'
    And headers headers
    And request
    """
    {
      "active" : true,
      "personal" : {
        "preferredContactTypeId" : "002",
        "lastName" : "User",
        "firstName" : "Another",
        "email" : "another.user@folio.org"
      },
      "username" : "another_user",
      "patronGroup" : "503a81cd-6c26-400f-b620-14c08943697c",
      "expirationDate" : "2022-03-15T00:00:00.000Z",
      "id" : '#(user2Id)',
      "barcode" : '#(user2Barcode)',
      "departments":[]
    }
    """
    When method POST
    Then status 201

  Scenario: check out an item
    Given path 'circulation/check-out-by-barcode'
    And headers headers
    And request
    """
    {
      "itemBarcode" : '#(itemBarcode)',
      "userBarcode" : '#(user1Barcode)',
      "servicePointId" : '#(servicePointId)',
      "loanDate" : '#(currentDate)',
      "id" : '#(checkoutId)'
    }
    """
    When method POST
    Then status 201

  Scenario: create hold request
    Given path 'circulation/requests'
    And headers headers
    And request
    """
    {
      "requestType" : "Hold",
      "fulfilmentPreference" : "Hold Shelf",
      "item" : {
        "barcode" : '#(itemBarcode)'
      },
      "itemId" : '#(itemId)',
      "requester" : {
        "barcode" : '#(user2Barcode)'
      },
      "requesterId" : '#(user2Id)',
      "requestLevel": "Item",
      "instanceId": "#(instanceId)",
      "holdingsRecordId": "#(holdingsRecordId)",
      "pickupServicePointId" : '#(servicePointId)',
      "requestDate" : '#(currentDate)',
      "id" : '#(requestId)'
    }
    """
    When method POST
    Then status 201
    * call pause 5

  Scenario: perform return: new retrieval queue record should be created
    Given path 'remote-storage/retrievals'
    And headers headers
    When method get
    Then status 200
    * def initialRecordsCount = $.totalRecords

    Given url edgeUrl
    And path '/caiasoftService/RequestBarcodes/', itemBarcode, '/reshelved/', remoteStorageId
    And param apikey = apikey
    And request ''
    When method POST
    Then status 201
    And match $.isHoldRecallRequestExist == true

    Given url baseUrl
    And path 'remote-storage/retrievals'
    And headers headers
    When method get
    Then status 200
    * def newRecordsCount = $.totalRecords
    * match (newRecordsCount - initialRecordsCount) == 1

  # clear test data
  Scenario: delete remote storage configuration
    Given path '/remote-storage/configurations', remoteStorageId
    And headers headers
    When method DELETE
    Then status 204

  Scenario: delete location mapping
    Given path '/remote-storage/mappings', remoteFolioLocationId
    And headers headers
    When method DELETE
    Then status 204

  Scenario: close request
    Given path 'circulation/requests', requestId
    And headers headers
    When method GET
    Then status 200
    * def requestJson = $

    * set requestJson.status = "Closed - Cancelled"
    * set requestJson.cancelledByUserId = user2Id
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

  Scenario: delete holding
    Given path 'holdings-storage/holdings', holdingsRecordId
    And headers headers
    When method DELETE
    Then status 204

  Scenario: delete instance
    Given path 'inventory/instances', instanceId
    And headers headers
    When method DELETE
    Then status 204

  Scenario: delete sample user
    Given path 'users', user1Id
    And headers headers
    When method DELETE
    Then status 204

  Scenario: delete another user
    Given path 'users', user2Id
    And headers headers
    When method DELETE
    Then status 204