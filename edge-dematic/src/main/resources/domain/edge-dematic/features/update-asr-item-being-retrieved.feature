Feature: test asrService/asr/updateASRItemStatusBeingRetrieved request
  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }

    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

    * callonce variables
    * def itemId = callonce uuid4
    * def itemBarcode = callonce barcode3

  Scenario: create and check out item
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
    * def response = $

    * def loanDate = call isoDate
    * def checkoutId = call uuid5

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
    And match $.item.status.name == 'Checked out'

  Scenario: make call to edge-dematic API
    Given url edgeUrl
    And path 'asrService/asr/updateASRItemStatusBeingRetrieved', storageId
    And param apikey = apikey
    And request
    """
    <updateASRItem>
      <itemBarcode>#(itemBarcode)</itemBarcode>
      <itemStatus>RETRIEVING</itemStatus>
      <operatorId>10001</operatorId>
    </updateASRItem>
    """
    When method POST
    Then status 201

  Scenario: verify that item is available
    Given path 'inventory/items', itemId
    And headers headers
    When method GET
    Then status 200
    And match $.status.name == 'Available'