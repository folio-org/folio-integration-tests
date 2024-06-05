# Created for MODORDERS-984
Feature: Unreceive a piece and check the order line

  Background:
    * url baseUrl
    * print karate.info.scenarioName

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
    * def unreceivePiece = read('classpath:thunderjet/mod-orders/reusable/unreceive-piece.feature')

    * configure retry = { count: 10, interval: 5000 }

  @Positive
  Scenario: Unreceive a piece and check the order line
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def titleId1 = call uuid
    * def titleId2 = call uuid
    * def pieceId1 = call uuid
    * def pieceId2 = call uuid

    * print '1. Prepare finances'
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 100 }

    * print '2. Create an order'
    * def v = callonce createOrder { id: '#(orderId)' }

    * print '3. Create a package order line'
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', isPackage: true }

    * print '4. Open the order'
    * def v = callonce openOrder { orderId: "#(orderId)" }

    * print '5. Create 2 titles and pieces'
    * def v = call createTitle { titleId: "#(titleId1)", poLineId: "#(poLineId)" }
    * def v = call createPiece { pieceId: "#(pieceId1)", poLineId: "#(poLineId)", titleId: "#(titleId1)" }
    * def v = call createTitle { titleId: "#(titleId2)", poLineId: "#(poLineId)" }
    * def v = call createPiece { pieceId: "#(pieceId2)", poLineId: "#(poLineId)", titleId: "#(titleId2)" }

    * print '6. Receive both pieces'
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
    * def v = call pause 300

    * print '7. Check the po line receipt status is Fully Received'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.receiptStatus == 'Fully Received'

    * print '8. Unreceive piece 1'
    * def v = call unreceivePiece { pieceId: "#(pieceId1)" }

    * print '9. Check the po line receipt status is Partially Received'
    Given path 'orders/order-lines', poLineId
    And retry until response.receiptStatus == 'Partially Received'
    When method GET
    Then status 200
    And match $.receiptStatus == 'Partially Received'

    * print '10. Unreceive piece 2'
    * def v = call unreceivePiece { pieceId: "#(pieceId2)" }

    * print '11. Check the po line receipt status is Awaiting Receipt'
    Given path 'orders/order-lines', poLineId
    And retry until response.receiptStatus == 'Awaiting Receipt'
    When method GET
    Then status 200
    And match $.receiptStatus == 'Awaiting Receipt'
