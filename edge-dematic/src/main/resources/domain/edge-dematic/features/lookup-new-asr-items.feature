Feature: test asrService/asr/lookupNewAsrItems request

  Background:
    * url baseUrl
    * callonce login admin

    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

    * callonce variables
    * def itemId = callonce uuid3
    * def itemBarcode = callonce barcode2

  Scenario: lookup new asr items to clean up accession queue
    Given url edgeUrl
    And path 'asrService/asr/lookupNewAsrItems', storageId
    And param apikey = apikey
    When method GET
    Then status 200

  Scenario: create item for accession
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
      "status" : {
        "name" : "Available"
      },
      "id" : #(itemId)
    }
    """
    When method POST
    Then status 201

    * def itemJson = $
    * set itemJson.temporaryLocation = { id: "#(remoteLocationId)" }

    Given path 'inventory/items', itemId
    And headers headers
    And request itemJson
    When method PUT
    Then status 204

  Scenario: lookup new asr items
    Given url edgeUrl
    And path 'asrService/asr/lookupNewAsrItems', storageId
    And param apikey = apikey
    When method GET
    Then status 200
    * def resp = $
    And match resp count(/asrItems//asrItem) == 1
    And match resp //asrItems/asrItem/itemNumber == itemBarcode

  Scenario: subsequent request should respond with empty result
    Given url edgeUrl
    And path 'asrService/asr/lookupNewAsrItems', storageId
    And param apikey = apikey
    When method GET
    Then status 200
    And match $ == '<asrItems/>'