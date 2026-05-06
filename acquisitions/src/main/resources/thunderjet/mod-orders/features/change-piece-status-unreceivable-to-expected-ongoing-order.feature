# For MODORDERS-984, MODORDERS-1027, https://foliotest.testrail.io/index.php?/cases/view/430268
Feature: Change piece status from Unreceivable to Expected for ongoing order with two pieces

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
    * configure retry = { count: 10, interval: 5000 }
        
    # Create fund and budget
    * def fundId = call uuid
    * def budgetId = call uuid
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 100 }
    * configure headers = headersUser

  @C430268
  @Positive
  Scenario: Change piece status from Unreceivable to Expected for ongoing order with two pieces
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Create an Ongoing order
    * def v = call createOrder { id: '#(orderId)', orderType: 'Ongoing', ongoing: { isSubscription: false, interval: 365, manualRenewal: false, reviewPeriod: 30 } }

    # 2. Create a physical PO line with quantity 2 and synchronized receiving workflow (Instance, Holding, Item)
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10, quantity: 2 }

    # 3. Open the order'
    * def v = call openOrder { orderId: '#(orderId)' }

    # 4. Get the two pieces created for the PO line
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    And param limit = 100
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def piece1 = $.pieces[0]
    * def piece2 = $.pieces[1]
    * def pieceId1 = piece1.id
    * def pieceId2 = piece2.id

    # 5. Set first piece status to Unreceivable
    * set piece1.receivingStatus = 'Unreceivable'
    Given path 'orders/pieces', pieceId1
    And request piece1
    When method PUT
    Then status 204
    * def v = call verifyPieceReceivingStatus { _pieceId: '#(pieceId1)', _receivingStatus: 'Unreceivable' }

    # 6. Receive the second piece via check-in
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
    * def v = call verifyPieceReceivingStatus { _pieceId: '#(pieceId2)', _receivingStatus: 'Received' }

    # 7. Verify PO line receipt status is Ongoing
    * def v = call verifyPoLineReceiptStatus { _poLineId: '#(poLineId)', _receiptStatus: 'Ongoing' }

    # 8. Change first piece status from Unreceivable back to Expected
    Given path 'orders/pieces', pieceId1
    When method GET
    Then status 200
    * def piece1 = $
    * set piece1.receivingStatus = 'Expected'
    Given path 'orders/pieces', pieceId1
    And request piece1
    When method PUT
    Then status 204

    # 9. Verify first piece status is Expected
    * def v = call verifyPieceReceivingStatus { _pieceId: '#(pieceId1)', _receivingStatus: 'Expected' }

    # 10. Verify second piece is still Received
    * def v = call verifyPieceReceivingStatus { _pieceId: '#(pieceId2)', _receivingStatus: 'Received' }

    # 11. Verify PO line receipt status remains Ongoing (ongoing order)
    * def v = call verifyPoLineReceiptStatus { _poLineId: '#(poLineId)', _receiptStatus: 'Ongoing' }


