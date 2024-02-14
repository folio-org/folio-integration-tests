@parallel=false
# for https://issues.folio.org/browse/MODORDERS-984
Feature: Unreceive a piece and check the order line

  Background:
    * print karate.info.scenarioName

    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')
    * def createTitle = read('classpath:thunderjet/mod-orders/reusable/create-title.feature')
    * def createPiece = read('classpath:thunderjet/mod-orders/reusable/create-piece.feature')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4
    * def titleId1 = callonce uuid5
    * def titleId2 = callonce uuid6
    * def pieceId1 = callonce uuid7
    * def pieceId2 = callonce uuid8

    * configure retry = { count: 10, interval: 5000 }


  Scenario: Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: #(fundId) }
    * def v = call createBudget { id: #(budgetId), fundId: #(fundId), allocated: 100 }


  Scenario: Create an order
    * def v = callonce createOrder { id: #(orderId) }


  Scenario: Create a package order line
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId), isPackage: true }


  Scenario: Open the order
    * def v = callonce openOrder { orderId: "#(orderId)" }


  Scenario: Create 2 titles and pieces
    * def v = call createTitle { titleId: "#(titleId1)", poLineId: "#(poLineId)" }
    * def v = call createPiece { pieceId: "#(pieceId1)", poLineId: "#(poLineId)", titleId: "#(titleId1)" }
    * def v = call createTitle { titleId: "#(titleId2)", poLineId: "#(poLineId)" }
    * def v = call createPiece { pieceId: "#(pieceId2)", poLineId: "#(poLineId)", titleId: "#(titleId2)" }


  Scenario: Receive both pieces
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
            },
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
    And match $.receivingResults[0].processedSuccessfully == 2

    # Wait a bit for the po line to be updated
    * call pause 300


  Scenario: Check the po line receipt status is Fully Received
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.receiptStatus == 'Fully Received'


  Scenario: Unreceive piece 1
    # Get piece 1
    Given path 'orders/pieces', pieceId1
    When method GET
    Then status 200
    * def piece = $

    # Unreceive it by changing receivingStatus and removing locationId
    * set piece.receivingStatus = 'Expected'
    * remove piece.locationId
    Given path 'orders/pieces', pieceId1
    And param deleteHoldings = false
    And request piece
    When method PUT
    Then status 204

    # Wait a bit for the po line to be updated
    * call pause 300


  Scenario: Check the po line receipt status is Partially Received
    Given path 'orders/order-lines', poLineId
    And retry until response.receiptStatus == 'Partially Received'
    When method GET
    Then status 200
    And match $.receiptStatus == 'Partially Received'


  Scenario: Unreceive piece 2
    # Get piece 2
    Given path 'orders/pieces', pieceId2
    When method GET
    Then status 200
    * def piece = $

    # Unreceive it by changing receivingStatus and removing locationId
    * set piece.receivingStatus = 'Expected'
    * remove piece.locationId
    Given path 'orders/pieces', pieceId2
    And param deleteHoldings = false
    And request piece
    When method PUT
    Then status 204

    # Wait a bit for the po line to be updated
    * call pause 300


  Scenario: Check the po line receipt status is Awaiting Receipt
    Given path 'orders/order-lines', poLineId
    And retry until response.receiptStatus == 'Awaiting Receipt'
    When method GET
    Then status 200
    And match $.receiptStatus == 'Awaiting Receipt'
