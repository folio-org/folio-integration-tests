@parallel=false
# for https://issues.folio.org/browse/MODORDERS-519
Feature: Receive piece against package POL

  Background:
    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
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
    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}


  Scenario: Create an order
    * configure headers = headersUser
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201


  Scenario: Create an order line with isPackage
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.isPackage = true
    * set poLine.checkinItems = true
    * set poLine.physical.createInventory = 'Instance, Holding, Item'
    * set poLine.fundDistribution[0].fundId = fundId

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201


  Scenario: Open the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

    # Check the order line does not have an instanceId
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == '#notpresent'

    # Check no piece was created when the order was opened
    # NOTE: this is strange to call orders-storage, but the UI is doing it too
    Given path 'orders-storage/pieces'
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
      format: "Electronic",
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

    # Check piece 1 receivingStatus
    Given path 'orders-storage/pieces', pieceId1
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'


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
      format: "Electronic",
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
      format: "Electronic",
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
    Given path 'orders-storage/pieces', pieceId2
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'


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
    Given path 'orders-storage/pieces', pieceId3
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'


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
              "pieceId": "#(pieceId2)"
            },
            {
              "itemStatus": "On order",
              "pieceId": "#(pieceId3)"
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
    Given path 'orders-storage/pieces', pieceId2
    When method GET
    Then status 200
    And match $.receivingStatus == 'Expected'

    # Check piece 3 receivingStatus
    Given path 'orders-storage/pieces', pieceId3
    When method GET
    Then status 200
    And match $.receivingStatus == 'Expected'
