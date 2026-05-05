# For MODORDERS-1297, MODORDERS-1299, https://foliotest.testrail.io/index.php?/cases/view/784414
Feature: P/E Mix Independent Change Instance Connection Find Or Create New Delete Holdings

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

  @C784414
  @Positive
  Scenario: Item Appears Under New Holding After Instance Connection Change With Find Or Create New For P/E Mix Independent Workflow
    * def instanceId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def pieceId3 = call uuid

    # 1. Create Target Instance #1 Without Holdings
    * configure headers = headersAdmin
    * table instanceData
      | id         | title              | instanceTypeId       |
      | instanceId | 'Instance C784414' | globalInstanceTypeId |
    * def v = call createInstance instanceData

    # 2. Create P/E Mix Order With Independent Receiving Workflow And Open It
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    * def locations =
    """
    [
      { locationId: '#(globalLocationsId)',  quantity: 1, quantityPhysical: 1   },
      { locationId: '#(globalLocationsId2)', quantity: 1, quantityElectronic: 1 }
    ]
    """
    * table orderLineData
      | id       | orderId | titleOrPackage  | orderFormat | checkinItems | quantityElectronic | listUnitPriceElectronic | createInventory           | eresourceCreateInventory  | eresourceMaterialType    | fundDistribution | locations |
      | poLineId | orderId | 'Title C784414' | 'P/E Mix'   | true         | 1                  | 1.0                     | 'Instance, Holding, Item' | 'Instance, Holding, Item' | globalMaterialTypeIdElec | []               | locations |
    * def v = call createOrderLine orderLineData
    * def v = call openOrder { orderId: '#(orderId)' }

    # 3.1 Get POL Instance ID And Auto-Created Holding IDs
    Given path 'orders/order-lines', poLineId
    And retry until response.instanceId != null && response.locations[0].holdingId != null && response.locations[1].holdingId != null
    When method GET
    Then status 200
    * def instanceIdOld = response.instanceId
    * def originalHoldingIds = karate.jsonPath(response, '$.locations[*].holdingId')

    # 3.2 Get Title ID
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    * def titleId = response.titles[0].id

    # 4.1 Add Piece In New Location Loc3
    * table pieceData
      | id       | poLineId | titleId | locationId         | useLocationId | format     | createItem |
      | pieceId3 | poLineId | titleId | globalLocationsId3 | true          | 'Physical' | true       |
    * def v = call createPieceWithHoldingOrLocation pieceData

    # 4.2 Get Holding ID Created For Piece In Loc3 (Different From Original POL Holdings)
    Given path 'orders/pieces', pieceId3
    And retry until response.holdingId != null && originalHoldingIds.indexOf(response.holdingId) < 0
    When method GET
    Then status 200
    * def holdingId3 = response.holdingId

    # 4.3 Receive The Piece In Loc3
    * table receivePiecesData
      | pieceId  | poLineId | holdingId  |
      | pieceId3 | poLineId | holdingId3 |
    * def v = call receivePieceWithHolding receivePiecesData

    # 5. Change Instance Connection To Instance #1 With "Find Or Create" And Delete Abandoned Holdings
    * table instanceChangeData
      | poLineId | instanceId | holdingsOperation | deleteAbandonedHoldings |
      | poLineId | instanceId | 'Find or Create'  | true                    |
    * def v = call changeOrderLineInstanceConnection instanceChangeData

    # 6.1 Verify POL Instance ID Updated And POL Locations No Longer Reference Old Holdings
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

    # 6.2 Verify Instance #1 Has Three Holdings
    * configure headers = headersAdmin
    * def hasAllExpectedLocations =
    """
    function(response) {
      if (response.totalRecords != 3) return false;
      var locs = karate.jsonPath(response, '$.holdingsRecords[*].permanentLocationId');
      return locs.indexOf(globalLocationsId)  >= 0
          && locs.indexOf(globalLocationsId2) >= 0
          && locs.indexOf(globalLocationsId3) >= 0;
    }
    """
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    And retry until hasAllExpectedLocations(response)
    When method GET
    Then status 200
    * def loc3Holding = karate.jsonPath(response, "$.holdingsRecords[?(@.permanentLocationId=='" + globalLocationsId3 + "')]")[0]
    * def newHoldingId3 = loc3Holding.id

    # 6.3 Verify Received Item Is Included In The Loc3 Holding On Instance #1
    Given path 'inventory/items'
    And param query = 'holdingsRecordId==' + newHoldingId3
    And retry until response.totalRecords == 1
    When method GET
    Then status 200

    # 6.4 Verify Old Instance No Longer Has Any Holdings
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceIdOld
    And retry until response.totalRecords == 0
    When method GET
    Then status 200
