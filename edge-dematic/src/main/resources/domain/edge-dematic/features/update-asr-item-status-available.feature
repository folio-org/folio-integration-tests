Feature: test asrService/asr/updateASRItemStatusAvailable request

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }

    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

    * callonce variables

    * def itemId = callonce uuid6
    * def itemBarcode = callonce barcode4
    * def requestId = callonce uuid7

  Scenario: create and check out item, create hold request
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

    * def loanDate = call isoDate
    * def checkoutId = callonce uuid8

    Given path 'circulation/check-out-by-barcode'
    And headers headers
    And request
    """
    {
      "itemBarcode" : "#(itemBarcode)",
      "userBarcode" : "#(user1Barcode)",
      "servicePointId" : "#(servicePointId)",
      "loanDate" : "#(loanDate)",
      "id" : "#(checkoutId)"
    }
    """
    When method POST
    Then status 201

    * def requestDate = call isoDate

    Given path 'circulation/requests'
    And headers headers
    And request
    """
    {
      "requestType" : "Hold",
      "fulfilmentPreference" : "Hold Shelf",
      "item" : {
        "barcode" : "#(itemBarcode)"
      },
      "itemId" : "#(itemId)",
      "requester" : {
        "barcode" : "#(user2Barcode)"
      },
      "requesterId" : "#(user2Id)",
      "pickupServicePointId" : "#(servicePointId)",
      "requestDate" : "#(requestDate)",
      "id" : "#(requestId)"
    }
    """
    When method POST
    Then status 201
    And match $.status == 'Open - Not yet filled'

  Scenario: make call to edge-dematic API
    Given url edgeUrl
    And path 'asrService/asr/updateASRItemStatusAvailable', storageId
    And param apikey = apikey
    And request
    """
    <updateASRItem>
      <itemBarcode>#(itemBarcode)</itemBarcode>
      <itemStatus>AVAILABLE</itemStatus>
      <operatorId>10001</operatorId>
    </updateASRItem>
    """
    When method POST
    Then status 201

  Scenario: verify that request status changed
    Given path 'circulation/requests', requestId
    And headers headers
    When method GET
    Then status 200
    And match $.status == 'Open - Awaiting pickup'