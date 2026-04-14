# For MODORDERS-1410, https://foliotest.testrail.io/index.php?/cases/view/1273167
Feature: Unopen Order With Synchronized And Independent POLs Deletes Only Empty Holding

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

  @C1273167
  @Positive
  Scenario: Unopen Order With Synchronized And Independent POLs - Only Empty Holding Deleted
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLine1Id = call uuid
    * def poLine2Id = call uuid
    * def pieceId = call uuid
    * def locId = globalLocationsId
    * def loc2Id = globalLocationsId2

    # 1. Create Fund And Budget
    * print '1. Create Fund And Budget'
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 10000, fundId: '#(fundId)', status: 'Active' }

    # 2. Create Order With POL1 (Synchronized, Instance Holdings Item) And POL2 (Independent, Instance Holdings)
    * print '2. Create Order With POL1 (Synchronized, Instance Holdings Item) And POL2 (Independent, Instance Holdings)'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)', orderType: 'One-Time' }
    * def v = call createOrderLine { id: '#(poLine1Id)', orderId: '#(orderId)', fundId: '#(fundId)', quantity: 1, createInventory: 'Instance, Holding, Item', checkinItems: false }
    * def locations2 =
    """
    [
      { locationId: '#(loc2Id)', quantityPhysical: 1, quantity: 1 }
    ]
    """
    * def v = call createOrderLine { id: '#(poLine2Id)', orderId: '#(orderId)', fundId: '#(fundId)', quantity: 1, locations: '#(locations2)', createInventory: 'Instance, Holding', checkinItems: true }

    # 3. Open Order
    * print '3. Open Order'
    * def v = call openOrder { orderId: '#(orderId)' }

    # 4. Get Instance IDs And Retrieve Holdings And Item Created
    * print '4. Get Instance IDs And Retrieve Holdings And Item Created'
    Given path 'orders/order-lines', poLine1Id
    And retry until response.instanceId != null
    When method GET
    Then status 200
    * def instance1Id = response.instanceId

    Given path 'orders/order-lines', poLine2Id
    And retry until response.instanceId != null
    When method GET
    Then status 200
    * def instance2Id = response.instanceId

    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instance1Id
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    * def holding1Id = response.holdingsRecords[0].id

    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + holding1Id
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    * def item1Id = response.items[0].id

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instance2Id
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    * def holding2Id = response.holdingsRecords[0].id
    * configure headers = headersUser

    # 5. Get Title For POL2 And Add Piece To POL2 Holding
    * print '5. Get Title For POL2 And Add Piece To POL2 Holding'
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLine2Id
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def title2Id = $.titles[0].id

    * def v = call createPieceWithHoldingOrLocation { id: '#(pieceId)', poLineId: '#(poLine2Id)', titleId: '#(title2Id)', holdingId: '#(holding2Id)' }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 6. Unopen Order - Click "Delete Holdings And Items" In The Modal
    * print '6. Unopen Order - Click "Delete Holdings And Items" In The Modal'
    * def v = call unopenOrder { orderId: '#(orderId)', deleteHoldings: true }

    # 7. Verify Order Workflow Status Is "Pending"
    * print '7. Verify Order Workflow Status Is "Pending"'
    Given path 'orders/composite-orders', orderId
    And retry until response.workflowStatus == 'Pending'
    When method GET
    Then status 200

    # 8. Verify POL1 Item Is Deleted (Synchronized POL, No Piece)
    * print '8. Verify POL1 Item Is Deleted (Synchronized POL, No Piece)'
    * configure headers = headersAdmin
    Given path 'inventory/items', item1Id
    And retry until responseStatus == 404
    When method GET

    # 9. Verify POL1 Holding Is Deleted (Empty After Item Deletion)
    * print '9. Verify POL1 Holding Is Deleted (Empty After Item Deletion)'
    Given path 'holdings-storage/holdings', holding1Id
    And retry until responseStatus == 404
    When method GET

    # 10. Verify POL2 Holding Still Exists (Has A Piece - Independent POL)
    * print '10. Verify POL2 Holding Still Exists (Has A Piece - Independent POL)'
    Given path 'holdings-storage/holdings', holding2Id
    When method GET
    Then status 200
    And match $.permanentLocationId == loc2Id
