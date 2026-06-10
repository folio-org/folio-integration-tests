# For MODORDERS-1299, MODORDSTOR-490, https://foliotest.testrail.io/index.php?/cases/view/784413
# Regression: changing instance connection on a P/E mix Synchronized POL using "Find or create new"
# with delete abandoned holdings must move both holdings (one per original location) onto the new
# instance, keep the received items under them, and clear the old instance of holdings.
Feature: P/E Mix Synchronized Change Instance Connection Find Or Create New Delete Holdings

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

  @C784413
  @Positive
  Scenario: Items Appear Under New Holdings After Instance Connection Change With Find Or Create For P/E Mix Synchronized Workflow
    * def instanceId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Create Target Instance #1 With No Holdings (TestRail Precondition #1)
    * configure headers = headersAdmin
    * def v = call createInstance { id: '#(instanceId)', title: 'Instance C784413', instanceTypeId: '#(globalInstanceTypeId)' }

    # 2. Create P/E Mix Synchronized Order — Loc1 Holds The Physical Piece, Loc2 Holds The Electronic — Then Open It (TestRail Precondition #2)
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    * def locations =
    """
    [
      { locationId: '#(globalLocationsId)',  quantity: 1, quantityPhysical: 1 },
      { locationId: '#(globalLocationsId2)', quantity: 1, quantityElectronic: 1 }
    ]
    """
    * def orderLineRequest =
    """
    {
      id: '#(poLineId)',
      orderId: '#(orderId)',
      titleOrPackage: 'Title C784413',
      orderFormat: 'P/E Mix',
      checkinItems: false,
      quantity: 1,
      quantityElectronic: 1,
      listUnitPriceElectronic: 1.0,
      createInventory: 'Instance, Holding, Item',
      eresourceCreateInventory: 'Instance, Holding, Item',
      eresourceMaterialType: '#(globalMaterialTypeIdElec)',
      fundDistribution: [],
      locations: '#(locations)'
    }
    """
    * def v = call createOrderLine orderLineRequest
    * def v = call openOrder { orderId: '#(orderId)' }

    # 3.1 Capture POL Instance And Auto-Created Holdings For Both Locations
    Given path 'orders/order-lines', poLineId
    And retry until response.instanceId != null && response.locations.length == 2 && response.locations[0].holdingId != null && response.locations[1].holdingId != null
    When method GET
    Then status 200
    * def instanceIdOld = response.instanceId
    * def originalHoldingIds = karate.jsonPath(response, '$.locations[*].holdingId')

    # 3.2 Map Old Holding IDs To Their Permanent Locations Via Holdings-Storage — POL locations[].locationId Is Cleared Once The Order Is Opened With createInventory Set To "Instance, Holding, Item"
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceIdOld
    And retry until response.totalRecords == 2
    When method GET
    Then status 200
    * def loc1HoldingOld = karate.jsonPath(response, "$.holdingsRecords[?(@.permanentLocationId=='" + globalLocationsId  + "')].id")[0]
    * def loc2HoldingOld = karate.jsonPath(response, "$.holdingsRecords[?(@.permanentLocationId=='" + globalLocationsId2 + "')].id")[0]
    * configure headers = headersUser

    # 3.3 Get Title And Auto-Created Pieces (One Physical, One Electronic)
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    * def titleId = response.titles[0].id

    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200
    * def physicalPieceId = karate.filter(response.pieces, function(p) { return p.format == 'Physical' })[0].id
    * def electronicPieceId = karate.filter(response.pieces, function(p) { return p.format == 'Electronic' })[0].id

    # 4. Receive Both Pieces Against Their Respective Holdings (TestRail Precondition #3)
    * table receivePiecesData
      | pieceId           | poLineId | holdingId      |
      | physicalPieceId   | poLineId | loc1HoldingOld |
      | electronicPieceId | poLineId | loc2HoldingOld |
    * def v = call receivePieceWithHolding receivePiecesData

    #========================================================================================================
    # TestRail Case Steps
    #========================================================================================================

    # 5. Change Instance Connection To Instance #1 With "Find Or Create" + Delete Abandoned Holdings (TestRail Steps 2-5)
    * table instanceChangeData
      | poLineId | instanceId | holdingsOperation | deleteAbandonedHoldings |
      | poLineId | instanceId | 'Find or Create'  | true                    |
    * def v = call changeOrderLineInstanceConnection instanceChangeData

    # 6.1 Verify POL Now Points To Instance #1 With Two Locations And Brand-New Holdings
    * def isPoLineUpdated =
    """
    function(response) {
      if (response.instanceId != instanceId || response.instanceId == instanceIdOld) return false;
      if (!response.locations || response.locations.length != 2) return false;
      var newIds = karate.jsonPath(response, '$.locations[*].holdingId');
      for (var i = 0; i < newIds.length; i++) {
        if (newIds[i] == null) return false;
        if (originalHoldingIds.indexOf(newIds[i]) >= 0) return false;
      }
      return true;
    }
    """
    Given path 'orders/order-lines', poLineId
    And retry until isPoLineUpdated(response)
    When method GET
    Then status 200

    # 6.2 Verify Instance #1 Now Has Exactly Two Holdings — Loc1 And Loc2 — And Capture The New Holding IDs Via Permanent Location (TestRail Steps 6-7)
    * configure headers = headersAdmin
    * def hasBothLocationHoldings =
    """
    function(response) {
      if (response.totalRecords != 2) return false;
      var locs = karate.jsonPath(response, '$.holdingsRecords[*].permanentLocationId');
      return locs.indexOf(globalLocationsId)  >= 0
          && locs.indexOf(globalLocationsId2) >= 0;
    }
    """
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    And retry until hasBothLocationHoldings(response)
    When method GET
    Then status 200
    * def loc1HoldingNew = karate.jsonPath(response, "$.holdingsRecords[?(@.permanentLocationId=='" + globalLocationsId  + "')].id")[0]
    * def loc2HoldingNew = karate.jsonPath(response, "$.holdingsRecords[?(@.permanentLocationId=='" + globalLocationsId2 + "')].id")[0]

    # 6.3 Verify The Received Items Now Live Under The New Holdings On Instance #1 (TestRail Step 7)
    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + loc1HoldingNew
    And retry until response.totalRecords == 1
    When method GET
    Then status 200

    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + loc2HoldingNew
    And retry until response.totalRecords == 1
    When method GET
    Then status 200

    # 6.4 Verify The Original Instance No Longer Has Any Holdings (TestRail Step 8)
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceIdOld
    And retry until response.totalRecords == 0
    When method GET
    Then status 200
