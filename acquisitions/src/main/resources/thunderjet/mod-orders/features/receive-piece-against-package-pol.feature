# For MODORDERS-519
@parallel=false
Feature: Receive piece against package POL

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = headersUser

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4
    * def titleId1 = callonce uuid5
    * def pieceId1 = callonce uuid6
    * def titleId2 = callonce uuid7
    * def pieceId2 = callonce uuid8
    * def pieceId3 = callonce uuid9


  Scenario: Create finances
    # this is needed for instance if a previous test does a rollover which changes the global fund
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 10000, fundId: '#(fundId)' }


  Scenario: Create an order
    * def v = call createOrder { id: '#(orderId)' }


  Scenario: Create an order line with isPackage
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', isPackage: true, checkinItems: true }


  Scenario: Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # Check the order line does not have an instanceId
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == '#notpresent'

    # Check no piece was created when the order was opened
    # NOTE: this is strange to call orders-storage, but the UI is doing it too
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 0


  Scenario: Create title 1

    Given path 'orders/titles'
    And request
    """
    {
      id: "#(titleId1)",
      title: "Sample Title",
      poLineId: "#(poLineId)"
    }
    """
    When method POST
    Then status 201


  Scenario: Create piece 1 for title 1

    Given path 'orders/pieces'
    And request
    """
    {
      id: "#(pieceId1)",
      format: "Physical",
      locationId: "#(globalLocationsId)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId1)"
    }
    """
    When method POST
    Then status 201


  Scenario: Receive piece 1

    Given path 'orders/check-in'
    And request
    """
    {
      toBeCheckedIn: [
        {
          checkedIn: 1,
          checkInPieces: [
            {
              id: "#(pieceId1)",
              itemStatus: "In process",
              displayOnHolding: false,
              enumeration: "#(pieceId1)",
              chronology: "#(pieceId1)",
              supplement: true,
              discoverySuppress: true,
              locationId: "#(globalLocationsId)",
              createItem: "true"
            }
          ],
          poLineId: "#(poLineId)"
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 1


    * print 'Check items after checkin first piece with createItem flag'
    * configure headers = headersAdmin
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 1
    * def itemForPiece1 = $.items[0]
    * def itemIdForPiece1 = itemForPiece1.id
    And match itemForPiece1.enumeration == '#(pieceId1)'
    And match itemForPiece1.chronology == '#(pieceId1)'
    And match itemForPiece1.discoverySuppress == null
    
    # Check piece 1 receivingStatus
    * configure headers = headersUser
    Given path 'orders/pieces', pieceId1
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'
    And match $.itemId == itemIdForPiece1
    And match $.enumeration == '#(pieceId1)'
    And match $.chronology == '#(pieceId1)'
    And match $.supplement == true
    And match $.discoverySuppress == true
    And match $.displayOnHolding == false

  Scenario: Create title 2

    Given path 'orders/titles'
    And request
    """
    {
      id: "#(titleId2)",
      title: "Sample Title",
      poLineId: "#(poLineId)"
    }
    """
    When method POST
    Then status 201


  Scenario: Create piece 2 for title 2

    Given path 'orders/pieces'
    And request
    """
    {
      id: "#(pieceId2)",
      format: "Physical",
      locationId: "#(globalLocationsId)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId2)"
    }
    """
    When method POST
    Then status 201


  Scenario: Create piece 3 for title 2

    Given path 'orders/pieces'
    And request
    """
    {
      id: "#(pieceId3)",
      format: "Physical",
      locationId: "#(globalLocationsId)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId2)"
    }
    """
    When method POST
    Then status 201


  Scenario: Receive piece 2

    Given path 'orders/check-in'
    And request
    """
    {
      toBeCheckedIn: [
        {
          checkedIn: 1,
          checkInPieces: [
            {
              id: "#(pieceId2)",
              itemStatus: "In process",
              displayOnHolding: false,
              enumeration: "#(pieceId2)",
              chronology: "#(pieceId2)",
              supplement: true,
              discoverySuppress: true,
              locationId: "#(globalLocationsId)"
            }
          ],
          poLineId: "#(poLineId)"
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 1

    # Check piece 2 receivingStatus
    Given path 'orders/pieces', pieceId2
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'
    And match $.enumeration == '#(pieceId2)'
    And match $.chronology == '#(pieceId2)'
    And match $.discoverySuppress == true
    And match $.displayOnHolding == false
    And match $.supplement == true

  Scenario: Receive piece 3

    Given path 'orders/check-in'
    And request
    """
    {
      toBeCheckedIn: [
        {
          checkedIn: 1,
          checkInPieces: [
            {
              id: "#(pieceId3)",
              itemStatus: "In process",
              displayOnHolding: false,
              enumeration: "#(pieceId3)",
              chronology: "#(pieceId3)",
              supplement: true,
              discoverySuppress: true,
              locationId: "#(globalLocationsId)"
            }
          ],
          poLineId: "#(poLineId)"
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 1

    # Check piece 3 receivingStatus
    Given path 'orders/pieces', pieceId3
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'
    And match $.enumeration == '#(pieceId3)'
    And match $.chronology == '#(pieceId3)'
    And match $.discoverySuppress == true
    And match $.displayOnHolding == false
    And match $.supplement == true

  Scenario: Unreceive pieces 2 and 3

    Given path 'orders/receive'
    And request
    """
    {
      toBeReceived: [
        {
          "poLineId": "#(poLineId)",
          "received": 2,
          "receivedItems": [
            {
              "itemStatus": "On order",
              "pieceId": "#(pieceId2)",
              "displayOnHolding": true,
              "chronology": "pieceId1Unreceived",
              "enumeration": "pieceId1Unreceived"
            },
            {
              "itemStatus": "On order",
              "pieceId": "#(pieceId3)",
              "displayOnHolding": true,
              "chronology": "pieceId2Unreceived",
              "enumeration": "pieceId2Unreceived"
            }
          ]
        }
      ],
      totalRecords: 2
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 2

    # Check piece 2 receivingStatus
    Given path 'orders/pieces', pieceId2
    When method GET
    Then status 200
    And match $.receivingStatus == 'Expected'
    And match $.enumeration == 'pieceId1Unreceived'
    And match $.chronology == 'pieceId1Unreceived'
    And match $.discoverySuppress == true
    And match $.displayOnHolding == true
    And match $.supplement == true

    # Check piece 3 receivingStatus
    Given path 'orders/pieces', pieceId3
    When method GET
    Then status 200
    And match $.receivingStatus == 'Expected'
    And match $.enumeration == 'pieceId2Unreceived'
    And match $.chronology == 'pieceId2Unreceived'
    And match $.discoverySuppress == true
    And match $.displayOnHolding == true
    And match $.supplement == true