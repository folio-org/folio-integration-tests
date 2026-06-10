# For MODORDERS-749, MODORDSTOR-311, MODORDSTOR-458, MODORDSTOR-481, https://foliotest.testrail.io/index.php?/cases/view/359150
Feature: P/E Mix Change Instance Connection Find Or Create New Keep Holdings Same Location

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

  @C359150
  @Positive
  Scenario: P/E Mix Order Independent Workflow Change Instance With Find Or Create New And Keep Abandoned Holdings When POL Has Same Location For Physical And Electronic
    * def instanceId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def pieceId3 = call uuid
    * def pieceId4 = call uuid

    # 1. Create Instance #1 Without Holdings (Precondition)
    * print '1. Create Instance #1 Without Holdings (Precondition)'
    * configure headers = headersAdmin
    * def v = call createInstance { id: '#(instanceId)', title: 'Instance C359150', instanceTypeId: '#(globalInstanceTypeId)' }

    # 2. Create P/E Mix Order With Independent Workflow And Open It
    # Same Location (Loc1) For Physical And Electronic, Each Added As Separate Line With Quantity 1
    * print '2. Create P/E Mix Order With Independent Workflow And Open It'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }
    * def locations =
    """
    [
      {
        locationId: '#(globalLocationsId)',
        quantity: 1,
        quantityPhysical: 1
      },
      {
        locationId: '#(globalLocationsId)',
        quantity: 1,
        quantityElectronic: 1
      }
    ]
    """

    * def orderLineRequest =
    """
    {
      id: '#(poLineId)',
      orderId: '#(orderId)',
      titleOrPackage: 'Title C359150',
      orderFormat: 'P/E Mix',
      checkinItems: true,
      quantity: 1,
      quantityElectronic: 1,
      listUnitPriceElectronic: 1.0,
      createInventory: 'Instance, Holding, Item',
      eresourceCreateInventory: 'Instance, Holding, Item',
      eresourceMaterialType: '#(globalMaterialTypeIdElec)',
      fundDistribution: [ ],
      locations: '#(locations)'
    }
    """
    * def v = call createOrderLine orderLineRequest
    * def v = call openOrder { orderId: '#(orderId)' }

    # 3.1 Wait Until POL Has Instance ID And Auto-Created Holding ID
    * print '3.1 Wait Until POL Has Instance ID And Auto-Created Holding ID'
    Given path 'orders/order-lines', poLineId
    And retry until response.instanceId != null && response.locations[0].holdingId != null
    When method GET
    Then status 200
    * def instanceIdOld = response.instanceId

    # 3.2 Collect Both Loc1 Holdings That Exist On The Old Instance (Created During Order Open For Both Pieces)
    * print '3.2 Collect Both Loc1 Holdings Created On The Old Instance During Order Open'
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceIdOld + ' and permanentLocationId==' + globalLocationsId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200
    * def loc1HoldingIds = karate.jsonPath(response, '$.holdingsRecords[*].id')
    * configure headers = headersUser

    # 3.3 Get Title ID
    * print '3.3 Get Title ID'
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    * def titleId = response.titles[0].id

    # 4.1 Add First Physical Piece In New Location Loc2 (Different From POL) With Create Item Active
    # This Triggers Auto-Creation Of A Loc2 Holding On The Order's Instance
    * print '4.1 Add First Physical Piece In New Location Loc2 With Create Item Active'
    * def pieceId3Data = { id: '#(pieceId3)', poLineId: '#(poLineId)', titleId: '#(titleId)', locationId: '#(globalLocationsId2)', useLocationId: true, format: 'Physical', createItem: true }
    * def v = call createPieceWithHoldingOrLocation pieceId3Data

    # 4.2 Get Holding ID Created For First Piece In Loc2 (Must Differ From Both Loc1 Holdings)
    * print '4.2 Get Holding ID Created For First Piece In Loc2'
    Given path 'orders/pieces', pieceId3
    And retry until response.holdingId != null && loc1HoldingIds.indexOf(response.holdingId) < 0
    When method GET
    Then status 200
    * def holdingIdLoc2 = response.holdingId

    # 4.3 Add Second Physical Piece Reusing The Same Loc2 Holding (UI Adds Both Pieces To The Same Holding)
    * print '4.3 Add Second Physical Piece Reusing The Same Loc2 Holding'
    * def pieceId4Data = { id: '#(pieceId4)', poLineId: '#(poLineId)', titleId: '#(titleId)', holdingId: '#(holdingIdLoc2)', format: 'Physical', createItem: true }
    * def v = call createPieceWithHoldingOrLocation pieceId4Data

    # 4.4 Receive Both Physical Pieces In Loc2
    * print '4.4 Receive Both Physical Pieces In Loc2'
    * table receivePiecesData
      | pieceId  | poLineId | holdingId     |
      | pieceId3 | poLineId | holdingIdLoc2 |
      | pieceId4 | poLineId | holdingIdLoc2 |
    * def v = call receivePieceWithHolding receivePiecesData

    # 5. Change Instance Connection To Instance #1 With "Find Or Create" And Keep Abandoned Holdings
    * print '5. Change Instance Connection To Instance #1 With "Find Or Create" And Keep Abandoned Holdings'
    * table instanceChangeData
      | poLineId | instanceId | holdingsOperation | deleteAbandonedHoldings |
      | poLineId | instanceId | 'Find or Create'  | false                   |
    * def v = call changeOrderLineInstanceConnection instanceChangeData

    # 6.1 Verify POL Instance ID And UUID Updated To Instance #1 (MODORDSTOR-311 Fix)
    # POL Location No Longer References Any Of The Original Loc1 Holdings Or The Loc2 Holding
    * print '6.1 Verify POL Instance ID And UUID Updated To Instance #1'
    * def isPoLineUpdated =
    """
    function(response) {
      if (response.instanceId != instanceId || response.instanceId == instanceIdOld) return false;
      if (!response.locations || response.locations.length != 1) return false;
      var newHoldingId = response.locations[0].holdingId;
      if (newHoldingId == null) return false;
      return loc1HoldingIds.indexOf(newHoldingId) < 0 && newHoldingId != holdingIdLoc2;
    }
    """
    Given path 'orders/order-lines', poLineId
    And retry until isPoLineUpdated(response)
    When method GET
    Then status 200

    # 6.2 Verify Instance #1 Has Two Holdings (Loc1 For Both Physical And Electronic, Loc2 For Received Items)
    # Per MODORDSTOR-481: Loc1 Holding Is Not Split For Physical/Electronic With Same Location
    * print '6.2 Verify Instance #1 Has Two Holdings: Loc1 (Shared Physical+Electronic) And Loc2 (Received Items)'
    * configure headers = headersAdmin
    * def hasExpectedHoldings =
    """
    function(response) {
      if (response.totalRecords != 2) return false;
      var locs = karate.jsonPath(response, '$.holdingsRecords[*].permanentLocationId');
      return locs.indexOf(globalLocationsId) >= 0
      && locs.indexOf(globalLocationsId2) >= 0;
    }
    """
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    And retry until hasExpectedHoldings(response)
    When method GET
    Then status 200
    * def loc2HoldingNew = karate.jsonPath(response, "$.holdingsRecords[?(@.permanentLocationId=='" + globalLocationsId2 + "')]")[0]
    * def newHoldingIdLoc2 = loc2HoldingNew.id

    # 6.3 Verify Received Items Are Included In The Loc2 Holding On Instance #1
    * print '6.3 Verify Both Received Items Are Included In The Loc2 Holding On Instance #1'
    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + newHoldingIdLoc2
    And retry until response.totalRecords == 2
    When method GET
    Then status 200

    # 6.4 Verify Old Instance Retains All Three Original Holdings Without Items
    * print '6.4 Verify Old Instance Retains Three Holdings (Loc1, Loc1, Loc2) Without Items'
    * def oldInstanceHasThreeHoldings =
    """
    function(response) {
      if (response.totalRecords != 3) return false;
      var ids = karate.jsonPath(response, '$.holdingsRecords[*].id');
      if (ids.indexOf(holdingIdLoc2) < 0) return false;
      for (var i = 0; i < loc1HoldingIds.length; i++) {
        if (ids.indexOf(loc1HoldingIds[i]) < 0) return false;
      }
      return true;
    }
    """
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceIdOld
    And retry until oldInstanceHasThreeHoldings(response)
    When method GET
    Then status 200

    # 6.5 Verify Old Holdings No Longer Contain Items (Items Moved To New Instance)
    * print '6.5 Verify Old Loc2 Holding No Longer Contains Items'
    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + holdingIdLoc2
    And retry until response.totalRecords == 0
    When method GET
    Then status 200
