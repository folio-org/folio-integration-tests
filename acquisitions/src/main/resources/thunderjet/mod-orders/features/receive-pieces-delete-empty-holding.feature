# For MODORDERS-1402, MODORDERS-1408, https://foliotest.testrail.io/index.php?/cases/view/1045969
Feature: Receive Pieces For POL With Instance Holdings And Delete Empty Holding

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
    * configure retry = { count: 5, interval: 10000 }

    * callonce variables

  @C1045969
  @Positive
  Scenario: Receive Pieces For POL With Instance Holdings And Delete Empty Holding
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def loc1Id = globalLocationsId
    * def loc2Id = globalLocationsId2

    # 1. Create Fund And Budget
    * print '1. Create Fund And Budget'
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 10000, fundId: '#(fundId)', status: 'Active' }

    # 2. Create Ongoing Order
    * print '2. Create Ongoing Order'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)', orderType: 'Ongoing', ongoing: { isSubscription: false } }

    # 3. Create PO Line With 2 Locations, Create Inventory Instance Holdings, Quantity 2
    * print '3. Create PO Line With 2 Locations, Create Inventory Instance Holdings, Quantity 2'
    * def locations =
    """
    [
      { locationId: '#(loc1Id)', quantityPhysical: 1, quantity: 1 },
      { locationId: '#(loc2Id)', quantityPhysical: 1, quantity: 1 }
    ]
    """
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', quantity: 2, locations: '#(locations)', createInventory: 'Instance, Holding' }

    # 4. Open Order
    * print '4. Open Order'
    * def v = call openOrder { orderId: '#(orderId)' }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 5. Get Title ID From Order Line
    * print '5. Get Title ID From Order Line'
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleId = $.titles[0].id

    # 6. Get Instance ID From Order Line
    * print '6. Get Instance ID From Order Line'
    Given path 'orders/order-lines', poLineId
    And retry until response.instanceId != null
    When method GET
    Then status 200
    * def instanceId = response.instanceId

    # 7. Get Holdings Created For Both Locations
    * print '7. Get Holdings Created For Both Locations'
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def holding1Id = response.holdingsRecords[0].permanentLocationId == loc1Id ? response.holdingsRecords[0].id : response.holdingsRecords[1].id
    * def holding2Id = response.holdingsRecords[0].permanentLocationId == loc1Id ? response.holdingsRecords[1].id : response.holdingsRecords[0].id
    * configure headers = headersUser

    # 8. Get 2 Expected Pieces And Verify Their Holding IDs
    * print '8. Get 2 Expected Pieces And Verify Their Holding IDs'
    Given path 'orders/pieces'
    And param query = 'titleId==' + titleId + ' AND receivingStatus==Expected'
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def piece1 = karate.filter(response.pieces, function(p) { return p.holdingId == holding1Id })[0]
    * def piece2 = karate.filter(response.pieces, function(p) { return p.holdingId == holding2Id })[0]
    * def piece1Id = piece1.id
    * def piece2Id = piece2.id

    # 9. Receive Both Pieces: Move Piece1 From Loc1 Holding To Loc2 Holding, Receive Piece2 Into Its Own Loc2 Holding
    # Only piece1's holding changes - Loc1 holding becomes empty and should be deleted
    * print '9. Receive Both Pieces: Piece1 Moves To Loc2 Holding, Piece2 Stays In Loc2 Holding'
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
              id: '#(piece1Id)',
              itemStatus: 'In process',
              displayOnHolding: false,
              holdingId: '#(holding2Id)',
              createItem: false
            },
            {
              id: '#(piece2Id)',
              itemStatus: 'In process',
              displayOnHolding: false,
              holdingId: '#(holding2Id)',
              createItem: false
            }
          ],
          poLineId: '#(poLineId)'
        }
      ],
      totalRecords: 2
    }
    """
    When method POST
    Then status 200
    And match $.receivingResults[0].processedSuccessfully == 2

    # 10. Verify Both Pieces Are Received With Loc2 Holding
    * print '10. Verify Both Pieces Are Received With Loc2 Holding'
    Given path 'orders/pieces', piece1Id
    And retry until response.receivingStatus == 'Received'
    When method GET
    Then status 200
    And match $.holdingId == holding2Id

    Given path 'orders/pieces', piece2Id
    And retry until response.receivingStatus == 'Received'
    When method GET
    Then status 200
    And match $.holdingId == holding2Id

    # 11. Verify Loc1 Holding Is Deleted (Was Empty After Receiving)
    * print '11. Verify Loc1 Holding Is Deleted (Was Empty After Receiving)'
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings', holding1Id
    And retry until responseStatus == 404
    When method GET

    # 12. Verify Instance Has Only One Holding (Loc2) Without Items
    * print '12. Verify Instance Has Only One Holding (Loc2) Without Items'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.holdingsRecords[0].id == holding2Id
    And match $.holdingsRecords[0].permanentLocationId == loc2Id

    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + holding2Id
    When method GET
    Then status 200
    And match $.totalRecords == 0
