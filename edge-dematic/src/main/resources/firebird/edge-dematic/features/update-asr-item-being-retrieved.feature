Feature: test asrService/asr/updateASRItemStatusBeingRetrieved request
  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }

    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

    * callonce variables
    * def itemId = callonce uuid4
    * def itemBarcode = callonce barcode3

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
      "expirationDate" : "2030-03-15T00:00:00.000Z",
      "id" : "#(user1Id)",
      "barcode" : "#(user1Barcode)",
      "departments":[]
    }
    """
    When method POST
    Then status 201

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
      "id" : "#(itemId)"
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