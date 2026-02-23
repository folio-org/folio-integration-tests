# For MODORDERS-1366, https://foliotest.testrail.io/index.php?/cases/view/844840
@parallel=false
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

  @C844840
  @Positive
  Scenario: Piece received via receiving full-screen in a new holding can be edited
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def newLocationId = globalLocationsId2
    * def originalLocationId = globalLocationsId

    # 1: Create fund and budget
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)' }
    * configure headers = headersUser

    # 2: Create order
    * def v = call createOrder { 'id': '#(orderId)' }

    # 3: Create order line with quantity 1 and create inventory instance, holding, item
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

    # 4: Open order
    * def v = call openOrder { 'orderId': '#(orderId)' }

    # 5: Get title ID from order line
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleId = $.titles[0].id

    # 6: Get instance ID from order line
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def instanceId = $.instanceId

    # 7: Get holdings created for original location
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def originalHoldingId = $.holdingsRecords[0].id
    * configure headers = headersUser

    # 8: Get expected piece and verify it is in expected status with original holding ID
    Given path 'orders/pieces'
    And param query = 'titleId==' + titleId + ' AND receivingStatus==Expected'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.pieces[0].receivingStatus == 'Expected'
    And match $.pieces[0].holdingId == originalHoldingId
    And match $.pieces[0].locationId == '#notpresent'
    * def pieceId = $.pieces[0].id

    # 9: Receive piece with new location ID
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

    # 10: Verify piece is now received with new holding ID
    Given path 'orders/pieces', pieceId
    And retry until response.receivingStatus == 'Received'
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'
    And match $.holdingId == '#present'
    And match $.locationId == '#notpresent'
    * def newHoldingId = $.holdingId

    # 11: Edit received piece - add display summary and barcode
    * def receivedPiece = $
    * def testDisplaySummary = 'Test Display Summary For C844840'
    * def testBarcode = 'TEST-BARCODE-' + pieceId
    * set receivedPiece.displaySummary = testDisplaySummary
    * set receivedPiece.barcode = testBarcode
    Given path 'orders/pieces', pieceId
    And request receivedPiece
    When method PUT
    Then status 204

    # 12: Verify piece was successfully updated
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match $.displaySummary == testDisplaySummary
    And match $.barcode == testBarcode
    And match $.receivingStatus == 'Received'
    And match $.holdingId == newHoldingId
    And match $.locationId == '#notpresent'

    # 13: Verify new holding was created in different location
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings', newHoldingId
    When method GET
    Then status 200
    And match $.permanentLocationId == newLocationId
    And match $.instanceId == instanceId

    # 14: Verify instance has two holdings now
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match $.totalRecords == 2

    # 15: Verify item was created in new holding with correct barcode
    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + newHoldingId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.items[0].barcode == testBarcode
    And match $.items[0].status.name == 'In process'

  @Positive
  Scenario: Piece received via receiving full-screen in a new holding can be edited
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def newLocationId = globalLocationsId2
    * def originalLocationId = globalLocationsId

    # 1. Create fund and budget
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)' }
    * configure headers = headersUser

    # 2. Create order
    * def v = call createOrder { 'id': '#(orderId)' }

    # 3. Create order line with quantity 1 and create inventory instance, holding, item
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.physical.createInventory = 'Instance, Holding'
    * set poLine.cost.quantityPhysical = 1
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.locations[0].locationId = originalLocationId
    * set poLine.locations[0].quantityPhysical = 1
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    # 4. Open order
    * def v = call openOrder { 'orderId': '#(orderId)' }

    # 5. Get title ID from order line
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleId = $.titles[0].id

    # 6. Get instance ID from order line
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def instanceId = $.instanceId

    # 7. Get holdings created for original location
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def originalHoldingId = $.holdingsRecords[0].id
    * configure headers = headersUser

    # 8. Get expected piece and verify it is in expected status with original holding ID
    Given path 'orders/pieces'
    And param query = 'titleId==' + titleId + ' AND receivingStatus==Expected'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.pieces[0].receivingStatus == 'Expected'
    And match $.pieces[0].holdingId == originalHoldingId
    And match $.pieces[0].locationId == '#notpresent'
    * def pieceId = $.pieces[0].id

    # 9. Receive piece with new location ID
    Given path 'orders/check-in'
    And param deleteHoldings = true
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

    # 10. Verify piece is now received with new holding ID
    Given path 'orders/pieces', pieceId
    And retry until response.receivingStatus == 'Received'
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'
    And match $.holdingId == '#present'
    And match $.holdingId != originalHoldingId
    And match $.locationId == '#notpresent'
    * def newHoldingId = $.holdingId

    # 11. Verify that old holding is deleted
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings', originalHoldingId
    And retry until responseStatus == 404
    When method GET

    # 12. Verify new holding was created in different location
    Given path 'holdings-storage/holdings', newHoldingId
    And retry until responseStatus == 200
    When method GET
    And match $.permanentLocationId == newLocationId
    And match $.instanceId == instanceId

    # 13. Verify instance has only one holding now (the new one)
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    And retry until responseStatus == 200 && response.totalRecords == 1
    When method GET
    Then status 200
    * configure headers = headersUser

  @Positive
  Scenario: Holding referenced by another PO line should not be deleted during checkin with deleteHoldings flag
    * def fundId = call uuid
    * def budgetId = call uuid
    * def order1Id = call uuid
    * def order2Id = call uuid
    * def poLine1Id = call uuid
    * def poLine2Id = call uuid
    * def sharedLocationId = globalLocationsId
    * def newLocationId = globalLocationsId2

    # 1. Create fund and budget
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)' }
    * configure headers = headersUser

    # 2. Create first order
    * def v = call createOrder { 'id': '#(order1Id)' }

    # 3. Create first order line with quantity 1 at shared location, create inventory Instance, Holding
    * def poLine1 = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine1.id = poLine1Id
    * set poLine1.purchaseOrderId = order1Id
    * set poLine1.physical.createInventory = 'Instance, Holding'
    * set poLine1.cost.quantityPhysical = 1
    * set poLine1.fundDistribution[0].fundId = fundId
    * set poLine1.locations[0].locationId = sharedLocationId
    * set poLine1.locations[0].quantityPhysical = 1
    Given path 'orders/order-lines'
    And request poLine1
    When method POST
    Then status 201

    # 4. Open first order
    * def v = call openOrder { 'orderId': '#(order1Id)' }

    # 5. Get instance ID and holding ID from first order line
    Given path 'orders/order-lines', poLine1Id
    When method GET
    Then status 200
    * def instanceId = $.instanceId
    * def sharedHoldingId = $.locations[0].holdingId

    # 6. Verify shared holding exists
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings', sharedHoldingId
    When method GET
    Then status 200
    And match $.permanentLocationId == sharedLocationId
    * configure headers = headersUser

    # 7. Create second order
    * def v = call createOrder { 'id': '#(order2Id)' }

    # 8. Create second order line referencing the SAME holding as first order
    * def poLine2 = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine2.id = poLine2Id
    * set poLine2.purchaseOrderId = order2Id
    * set poLine2.physical.createInventory = 'None'
    * set poLine2.cost.quantityPhysical = 1
    * set poLine2.fundDistribution[0].fundId = fundId
    * set poLine2.locations[0].holdingId = sharedHoldingId
    * set poLine2.locations[0].quantityPhysical = 1
    Given path 'orders/order-lines'
    And request poLine2
    When method POST
    Then status 201

    # 9. Open second order
    * def v = call openOrder { 'orderId': '#(order2Id)' }

    # 10. Get expected piece from first order and verify it has the shared holding ID
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLine1Id + ' AND receivingStatus==Expected'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.pieces[0].holdingId == sharedHoldingId
    * def pieceId = $.pieces[0].id

    # 11. Receive piece from first order with deleteHoldings=true, moving to new location
    Given path 'orders/check-in'
    And param deleteHoldings = true
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
          poLineId: '#(poLine1Id)'
        }
      ],
      totalRecords: 1
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 1

    # 12. Verify piece is now received with a NEW holding ID (not the shared one)
    Given path 'orders/pieces', pieceId
    And retry until response.receivingStatus == 'Received'
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'
    And match $.holdingId == '#present'
    And match $.holdingId != sharedHoldingId
    * def newHoldingId = $.holdingId

    # 13. Verify that the shared holding is NOT deleted (because second order line still references it)
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings', sharedHoldingId
    When method GET
    Then status 200
    And match $.permanentLocationId == sharedLocationId

    # 14. Verify the new holding was created in the new location
    Given path 'holdings-storage/holdings', newHoldingId
    When method GET
    Then status 200
    And match $.permanentLocationId == newLocationId
    And match $.instanceId == instanceId

    # 15. Verify second order line still references the shared holding
    * configure headers = headersUser
    Given path 'orders/order-lines', poLine2Id
    When method GET
    Then status 200
    And match $.locations[0].holdingId == sharedHoldingId