# For MODORDERS-730, https://foliotest.testrail.io/index.php?/cases/view/358535
Feature: Item Appears Under Holdings After Instance Connection Change With Holding Setting Find Or Create

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

  @C358535
  @Positive
  Scenario: Item Appears Under Holdings After Instance Connection Change With Holding Setting Find Or Create
    # Generate unique identifiers for this test scenario
    * def newInstanceId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def pieceId1 = call uuid
    * def pieceId3 = call uuid
    * def locationId1 = call uuid
    * def locationId2 = call uuid
    * def locationId3 = call uuid
    * def codeSuffix = call random_string

    # 0. Create Local Locations For This Test Scenario (Avoid Using Global Locations)
    * print '0. Create Local Locations For This Test Scenario'
    * configure headers = headersAdmin
    * table testLocations
      | id            | code                       | institutionId                       | campusId                       | libraryId                       | servicePointId        |
      | locationId1   | 'LOC1-FC-' + codeSuffix    | globalLocationUnitsInstructionsId   | globalLocationUnitsCampusesId  | globalLocationUnitsLibrariesId  | globalServicePointsId |
      | locationId2   | 'LOC2-FC-' + codeSuffix    | globalLocationUnitsInstructionsId   | globalLocationUnitsCampusesId  | globalLocationUnitsLibrariesId  | globalServicePointsId |
      | locationId3   | 'LOC3-FC-' + codeSuffix    | globalLocationUnitsInstructionsId   | globalLocationUnitsCampusesId  | globalLocationUnitsLibrariesId  | globalServicePointsId |
    * def v = call createLocation testLocations

    # 1. Create Target Instance Title #2 Without Holdings (Precondition)
    * print '1. Create Target Instance Title #2 Without Holdings (Precondition)'
    * def v = call createInstance { id: '#(newInstanceId)', title: 'Title #2 Find Or Create', instanceTypeId: '#(globalInstanceTypeId)' }

    # 2. Create Physical One-Time Order With Independent Receiving Workflow And Two Locations
    * print '2. Create Physical One-Time Order With Independent Receiving Workflow And Two Locations'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    * def locations =
    """
    [
      { locationId: '#(locationId1)', quantity: 1, quantityPhysical: 1 },
      { locationId: '#(locationId2)', quantity: 1, quantityPhysical: 1 }
    ]
    """
    * def orderLineRequest =
    """
    {
      id: '#(poLineId)',
      orderId: '#(orderId)',
      titleOrPackage: 'Title #1 Find Or Create',
      orderFormat: 'Physical Resource',
      checkinItems: true,
      quantity: 2,
      createInventory: 'Instance, Holding, Item',
      fundDistribution: [],
      locations: '#(locations)'
    }
    """
    * def v = call createOrderLine orderLineRequest
    * def v = call openOrder { orderId: '#(orderId)' }

    # 3.1 Get POL Instance ID And Auto-Created Holdings In Loc1 And Loc2
    * print '3.1 Get POL Instance ID And Auto-Created Holdings In Loc1 And Loc2'
    Given path 'orders/order-lines', poLineId
    And retry until response.instanceId != null && response.locations[0].holdingId != null && response.locations[1].holdingId != null
    When method GET
    Then status 200
    * def instanceIdOld = response.instanceId
    * def holdingId1 = response.locations[0].holdingId
    * def holdingId2 = response.locations[1].holdingId

    # 3.2 Get Title ID For PO Line
    * print '3.2 Get Title ID For PO Line'
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def titleId = response.titles[0].id

    # 4. Add Piece In Existing Holding Loc1 With Create Item And Receive It
    * print '4. Add Piece In Existing Holding Loc1 With Create Item And Receive It'
    * def piece1Data = { id: '#(pieceId1)', poLineId: '#(poLineId)', titleId: '#(titleId)', holdingId: '#(holdingId1)', format: 'Physical', createItem: true }
    * def v = call createPieceWithHoldingOrLocation piece1Data
    * def v = call receivePieceWithHolding { pieceId: '#(pieceId1)', poLineId: '#(poLineId)', holdingId: '#(holdingId1)' }

    # 5.1 Add Piece In New Location Loc3 With Create Item (Creates New Holding Loc3)
    * print '5.1 Add Piece In New Location Loc3 With Create Item (Creates New Holding Loc3)'
    * def piece3Data = { id: '#(pieceId3)', poLineId: '#(poLineId)', titleId: '#(titleId)', locationId: '#(locationId3)', useLocationId: true, format: 'Physical', createItem: true }
    * def v = call createPieceWithHoldingOrLocation piece3Data

    # 5.2 Get Holding ID Created For Piece In Loc3
    * print '5.2 Get Holding ID Created For Piece In Loc3'
    Given path 'orders/pieces', pieceId3
    When method GET
    Then status 200
    * def holdingId3 = response.holdingId
    And match holdingId3 != holdingId1
    And match holdingId3 != holdingId2

    # 5.3 Receive The Piece In Loc3
    * print '5.3 Receive The Piece In Loc3'
    * def v = call receivePieceWithHolding { pieceId: '#(pieceId3)', poLineId: '#(poLineId)', holdingId: '#(holdingId3)' }

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 6. Change Instance Connection To Title #2 With "Find Or Create" And Keep Abandoned Holdings
    * print '6. Change Instance Connection To Title #2 With "Find Or Create" And Keep Abandoned Holdings'
    * def v = call changeOrderLineInstanceConnection { poLineId: '#(poLineId)', instanceId: '#(newInstanceId)', holdingsOperation: 'Find or Create', deleteAbandonedHoldings: false }

    # 7. Verify PO Line Instance ID Updated And Holdings Replaced
    * print '7. Verify PO Line Instance ID Updated And Holdings Replaced'
    * def isPoLineUpdated =
    """
    function(response) {
      if (response.instanceId != newInstanceId) return false;
      if (response.locations == null || response.locations.length != 2) return false;
      for (var i = 0; i < response.locations.length; i++) {
        var id = response.locations[i].holdingId;
        if (id == holdingId1 || id == holdingId2) return false;
      }
      return true;
    }
    """
    Given path 'orders/order-lines', poLineId
    And retry until isPoLineUpdated(response)
    When method GET
    Then status 200

    # 8.1 Verify Title #2 Has Three Holdings (Loc1, Loc2, Loc3)
    * print '8.1 Verify Title #2 Has Three Holdings (Loc1, Loc2, Loc3)'
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + newInstanceId
    And retry until response.totalRecords == 3
    When method GET
    Then status 200
    And match response.holdingsRecords[*].permanentLocationId contains locationId1
    And match response.holdingsRecords[*].permanentLocationId contains locationId2
    And match response.holdingsRecords[*].permanentLocationId contains locationId3

    # 8.2 Verify Two Received Items Exist For The PO Line
    * print '8.2 Verify Two Received Items Exist For The PO Line'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200

    # 9.1 Verify Title #1 Still Has Three Holdings (Kept) But No Items
    * print '9.1 Verify Title #1 Still Has Three Holdings (Kept) But No Items'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceIdOld
    And retry until response.totalRecords == 3
    When method GET
    Then status 200
    And match response.holdingsRecords[*].id contains holdingId1
    And match response.holdingsRecords[*].id contains holdingId2
    And match response.holdingsRecords[*].id contains holdingId3

    # 9.2 Verify No Items Remain Under Title #1 Holdings
    * print '9.2 Verify No Items Remain Under Title #1 Holdings'
    Given path 'inventory/items'
    And param query = 'holdingsRecordId==("' + holdingId1 + '" OR "' + holdingId2 + '" OR "' + holdingId3 + '")'
    And retry until response.totalRecords == 0
    When method GET
    Then status 200