# For MODORDERS-1366, https://foliotest.testrail.io/index.php?/cases/view/844840
Feature: Piece received via receiving full-screen in a new holding can be edited

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
    * configure retry = { count: 10, interval: 10000 }

    * callonce variables

  @Positive
  Scenario: Piece received via receiving full-screen in a new holding can be edited
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def newLocationId = globalLocationsId2
    * def originalLocationId = globalLocationsId

    # Step 1: Create fund and budget
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)' }
    * configure headers = headersUser

    # Step 2: Create order
    * def v = call createOrder { 'id': '#(orderId)' }

    # Step 3: Create order line with quantity 1 and create inventory instance, holding, item
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.physical.createInventory = 'Instance, Holding, Item'
    * set poLine.cost.quantityPhysical = 1
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.locations[0].locationId = originalLocationId
    * set poLine.locations[0].quantityPhysical = 1
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    # Step 4: Open order
    * def v = call openOrder { 'orderId': '#(orderId)' }

    # Step 5: Get title ID from order line
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleId = $.titles[0].id

    # Step 6: Get instance ID from order line
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def instanceId = $.instanceId

    # Step 7: Get holdings created for original location
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def originalHoldingId = $.holdingsRecords[0].id
    * configure headers = headersUser

    # Step 8: Get expected piece and verify it is in expected status with original holding ID
    Given path 'orders/pieces'
    And param query = 'titleId==' + titleId + ' AND receivingStatus==Expected'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.pieces[0].receivingStatus == 'Expected'
    And match $.pieces[0].holdingId == originalHoldingId
    And match $.pieces[0].locationId == '#notpresent'
    * def pieceId = $.pieces[0].id

    # Step 9: Receive piece with new location ID
    Given path 'orders/check-in'
    And request
    """
    {
      toBeCheckedIn: [
        {
          checkedIn: 1,
          checkInPieces: [
            {
              id: '#(pieceId)',
              itemStatus: 'In process',
              displayOnHolding: false,
              locationId: '#(newLocationId)',
              createItem: true
            }
          ],
          poLineId: '#(poLineId)'
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 1

    # Step 10: Verify piece is now received with new holding ID
    Given path 'orders/pieces', pieceId
    And retry until response.receivingStatus == 'Received'
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'
    And match $.holdingId == '#present'
    And match $.locationId == '#notpresent'
    * def newHoldingId = $.holdingId

    # Step 11: Edit received piece - add display summary and barcode
    * def receivedPiece = $
    * def testDisplaySummary = 'Test Display Summary For C844840'
    * def testBarcode = 'TEST-BARCODE-' + pieceId
    * set receivedPiece.displaySummary = testDisplaySummary
    * set receivedPiece.barcode = testBarcode
    Given path 'orders/pieces', pieceId
    And request receivedPiece
    When method PUT
    Then status 204

    # Step 12: Verify piece was successfully updated
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match $.displaySummary == testDisplaySummary
    And match $.barcode == testBarcode
    And match $.receivingStatus == 'Received'
    And match $.holdingId == newHoldingId
    And match $.locationId == '#notpresent'

    # Step 13: Verify new holding was created in different location
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings', newHoldingId
    When method GET
    Then status 200
    And match $.permanentLocationId == newLocationId
    And match $.instanceId == instanceId

    # Step 14: Verify instance has two holdings now
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match $.totalRecords == 2

    # Step 15: Verify item was created in new holding with correct barcode
    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + newHoldingId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.items[0].barcode == testBarcode
    And match $.items[0].status.name == 'In process'
