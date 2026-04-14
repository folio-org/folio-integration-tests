# For MODORDERS-1410, https://foliotest.testrail.io/index.php?/cases/view/1273160
Feature: Unopen Order Deletes Only Empty Holding For Two Locations

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
    * configure retry = { count: 5, interval: 5000 }

    * callonce variables

  @C1273160
  @Positive
  Scenario: Unopen Independent POL With 2 Locations And 1 Piece - Only Empty Holding Deleted
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def pieceId = call uuid
    * def loc1Id = globalLocationsId
    * def loc2Id = globalLocationsId2

    # 1. Create Fund And Budget
    * print '1. Create Fund And Budget'
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 10000, fundId: '#(fundId)', status: 'Active' }

    # 2. Create Order With 1 POL - Independent Workflow, Qty 2, 2 Locations, Instance Holdings
    * print '2. Create Order With 1 POL - Independent Workflow, Qty 2, 2 Locations, Instance Holdings'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)', orderType: 'One-Time' }
    * def locations =
    """
    [
      { locationId: '#(loc1Id)', quantityPhysical: 1, quantity: 1 },
      { locationId: '#(loc2Id)', quantityPhysical: 1, quantity: 1 }
    ]
    """
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', quantity: 2, locations: '#(locations)', createInventory: 'Instance, Holding', checkinItems: true }

    # 3. Open Order
    * print '3. Open Order'
    * def v = call openOrder { orderId: '#(orderId)' }

    # 4. Get Instance ID And Retrieve Both Holdings Created
    * print '4. Get Instance ID And Retrieve Both Holdings Created'
    Given path 'orders/order-lines', poLineId
    And retry until response.instanceId != null
    When method GET
    Then status 200
    * def instanceId = response.instanceId

    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200
    * def holding1Id = karate.filter(response.holdingsRecords, function(h) { return h.permanentLocationId == loc1Id })[0].id
    * def holding2Id = karate.filter(response.holdingsRecords, function(h) { return h.permanentLocationId == loc2Id })[0].id
    * configure headers = headersUser

    # 5. Get Title ID And Add Piece To Loc1 Holding
    * print '5. Get Title ID And Add Piece To Loc1 Holding'
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleId = $.titles[0].id

    * def v = call createPieceWithHoldingOrLocation { id: '#(pieceId)', poLineId: '#(poLineId)', titleId: '#(titleId)', holdingId: '#(holding1Id)' }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 6. Unopen Order - Click "Delete Holding" In The Modal
    * print '6. Unopen Order - Click "Delete Holding" In The Modal'
    * def v = call unopenOrder { orderId: '#(orderId)', deleteHoldings: true }

    # 7. Verify Order Workflow Status Is "Pending"
    * print '7. Verify Order Workflow Status Is "Pending"'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Pending'
    When method GET
    Then status 200

    # 8. Verify Loc2 Holding Is Deleted (Was Empty - No Piece)
    * print '8. Verify Loc2 Holding Is Deleted (Was Empty - No Piece)'
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings', holding2Id
    And retry until responseStatus == 404
    When method GET

    # 9. Verify Instance Has Only One Holding (Loc1) Without Items
    * print '9. Verify Instance Has Only One Holding (Loc1) Without Items'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.holdingsRecords[0].id == holding1Id
    And match $.holdingsRecords[0].permanentLocationId == loc1Id
