Feature: test Caiasoft accession request while creation of dublicated holding

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * callonce variables
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

  Scenario: create test data
     Given path '/remote-storage/configurations'
     And headers headers
     And request
     """
     {
         "id": "#(remoteStorageId)",
         "name": "RSTest",
         "providerName": "CAIA_SOFT",
         "url": "http://endpoint",
         "accessionDelay": 2,
         "accessionTimeUnit": "minutes",
         "accessionWorkflowDetails": "Duplicate holdings"
     }
     """
     When method POST
     Then status 201

     Given path 'remote-storage/mappings'
     And headers headers
     And request
     """
     {
       "folioLocationId": "#(remoteFolioLocationId)",
       "configurationId": "#(remoteStorageId)"
     }
     """
     When method POST
     Then status 201

    Given path '/inventory/instances'
    And headers headers
    And request
    """
    {
        "id": "#(instanceId)",
        "source": "FOLIO",
        "title": "Interesting Times",
        "alternativeTitles": [],
        "editions": [],
        "series": [],
        "instanceTypeId": "#(instanceTypeId)"
    }
    """
    When method POST
    Then status 201

    Given path 'holdings-storage/holdings'
    And headers headers
    And request
    """
    {
        "id": "#(holdingsRecordId)",
        "formerIds": [],
        "instanceId": "#(instanceId)",
        "permanentLocationId": "#(notRemoteFolioLocationId)",
        "effectiveLocationId": "#(notRemoteFolioLocationId)",
        "electronicAccess": [],
        "callNumber": "PR6056.I4588 B749 2016"
    }
    """
    When method POST
    Then status 201

    Given path 'inventory/items'
    And headers headers
    And request
    """
    {
        "id": "#(itemId)",
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
        "holdingsRecordId": "#(holdingsRecordId)",
        "barcode": "#(itemBarcode)",
        "itemLevelCallNumber": "TK5105.88815 . A58 2004 FT MEADE",
        "materialType": {
            "id": "1a54b431-2e4f-452d-9cae-9cee66c9a892",
            "name": "book"
        },
          "permanentLoanType": {
            "id": "2b94c631-fca9-4892-a730-03ee529ffe27",
            "name": "Can Circulate"
        },
        "permanentLocation": {
            "id": "#(notRemoteFolioLocationId)",
            "name": "Main Library"
        }
    }
    """
    When method POST
    Then status 201

    Given path 'inventory/items'
    And headers headers
    And request
    """
    {
        "id": "#(itemId2)",
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
        "holdingsRecordId": "#(holdingsRecordId)",
        "barcode": "#(itemBarcode2)",
        "itemLevelCallNumber": "TK5105.88815 . A58 2004 FT MEADE",
        "materialType": {
            "id": "1a54b431-2e4f-452d-9cae-9cee66c9a892",
            "name": "book"
        },
          "permanentLoanType": {
            "id": "2b94c631-fca9-4892-a730-03ee529ffe27",
            "name": "Can Circulate"
        },
        "permanentLocation": {
            "id": "#(notRemoteFolioLocationId)",
            "name": "Main Library"
        }
    }
    """
    When method POST
    Then status 201

  Scenario: accession item by barcode
    Given url edgeUrl
    And path '/caiasoftService/ItemBarcodes/', itemBarcode, '/accessioned/', remoteStorageId
    And param apikey = apikey
    When method GET
    Then status 200
    And match $.permanentLocationId == remoteFolioLocationId

  Scenario: item should be moved to dublicated holding
    Given path 'inventory/items/', itemId
    And headers headers
    When method GET
    Then status 200
    And match $.permanentLocation.id == remoteFolioLocationId

    * def dublicatedHoldingId =  $.holdingsRecordId

    Given path 'holdings-storage/holdings/', dublicatedHoldingId
    And headers headers
    When method GET
    Then status 200
    And match $.callNumber == 'PR6056.I4588 B749 2016'
    And match $.id != holdingsRecordId

    Given path 'inventory/items', itemId
    And headers headers
    When method DELETE
    Then status 204

    Given path 'holdings-storage/holdings', dublicatedHoldingId
    And headers headers
    When method DELETE
    Then status 204

  Scenario: clean test remote storage
    Given path '/remote-storage/configurations', remoteStorageId
    And headers headers
    When method DELETE
    Then status 204

  Scenario: clean test remote mapping
    Given path '/remote-storage/mappings', remoteFolioLocationId
    And headers headers
    When method DELETE
    Then status 204

  Scenario: clean test item2
    Given path 'inventory/items', itemId2
    And headers headers
    When method DELETE
    Then status 204

  Scenario: clean test holding record
    Given path 'holdings-storage/holdings', holdingsRecordId
    And headers headers
    When method DELETE
    Then status 204

  Scenario: clean test instance
    Given path 'inventory/instances', instanceId
    And headers headers
    When method DELETE
    Then status 204
