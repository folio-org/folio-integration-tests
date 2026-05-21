# For MODORDERS-1297, MODORDERS-1300, https://foliotest.testrail.io/index.php?/cases/view/784425
Feature: P/E Mix Synchronized Change Instance Connection Create New Delete Holdings

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

  @C784425
  @Positive
  Scenario: P/E Mix Order Synchronized Change Instance To Existing With Create New Holdings And Delete Abandoned Holdings
    * def instanceId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def preconditionHoldingId = call uuid
    * def pieceId3 = call uuid

    # 1. Create Instance #1 With One Holding In Loc1 (Precondition)
    * print '1. Create Instance #1 With One Holding In Loc1 (Precondition)'
    * configure headers = headersAdmin
    * def v = call createInstance { id: '#(instanceId)', title: 'Instance C784425', instanceTypeId: '#(globalInstanceTypeId)' }

    Given path 'holdings-storage/holdings'
    And request
    """
    {
      "id": "#(preconditionHoldingId)",
      "instanceId": "#(instanceId)",
      "permanentLocationId": "#(globalLocationsId)",
      "sourceId": "#(globalHoldingsSourceId)"
    }
    """
    When method POST
    Then status 201

    # 2. Create P/E Mix Order With Synchronized Workflow And Open It
    * print '2. Create P/E Mix Order With Synchronized Workflow And Open It'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }
    * def locations =
    """
    [
      { locationId: '#(globalLocationsId)', quantity: 2, quantityPhysical: 1, quantityElectronic: 1 }
    ]
    """

    * def orderLineRequest =
    """
    {
      id: '#(poLineId)',
      orderId: '#(orderId)',
      titleOrPackage: 'Title C784425',
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

    # 3.1 Get POL Instance ID And Auto-Created Holding ID In Loc1
    * print '3.1 Get POL Instance ID And Auto-Created Holding ID In Loc1'
    Given path 'orders/order-lines', poLineId
    And retry until response.instanceId != null && response.locations[0].holdingId != null
    When method GET
    Then status 200
    * def instanceIdOld = response.instanceId
    * def holdingId1 = response.locations[0].holdingId

    # 3.2 Get Title ID And Auto-Created Pieces
    * print '3.2 Get Title ID And Auto-Created Pieces'
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleId = $.titles[0].id

    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200
    * def physicalPieceId = karate.filter(response.pieces, function(p) { return p.format == 'Physical' })[0].id
    * def electronicPieceId = karate.filter(response.pieces, function(p) { return p.format == 'Electronic' })[0].id

    # 4.1 Add Piece In New Location Loc2
    * print '4.1 Add Piece In New Location Loc2'
    * def pieceRequest =
    """
    { id: '#(pieceId3)', poLineId: '#(poLineId)', titleId: '#(titleId)', locationId: '#(globalLocationsId2)', useLocationId: true, format: 'Physical', createItem: true }
    """
    * def v = call createPieceWithHoldingOrLocation pieceRequest

    # 4.2 Get Holding ID Created For Piece In Loc2
    * print '4.2 Get Holding ID Created For Piece In Loc2'
    Given path 'orders/pieces', pieceId3
    When method GET
    Then status 200
    * def holdingId2 = response.holdingId

    # 4.3 Receive All Pieces
    * print '4.3 Receive All Pieces'
    * table receivePiecesData
      | pieceId          | poLineId | holdingId  |
      | physicalPieceId  | poLineId | holdingId1 |
      | electronicPieceId| poLineId | holdingId1 |
      | pieceId3         | poLineId | holdingId2 |
    * def v = call receivePieceWithHolding receivePiecesData

    # 5. Change Instance Connection With "Create" Holdings Operation And Delete Abandoned Holdings
    * print '5. Change Instance Connection With "Create" Holdings Operation And Delete Abandoned Holdings'
    * table instanceChangeData
      | poLineId | instanceId | holdingsOperation | deleteAbandonedHoldings |
      | poLineId | instanceId | 'Create'          | true                    |
    * def v = call changeOrderLineInstanceConnection instanceChangeData

    # 6.1 Verify POL Instance ID And Locations Updated
    * print '6.1 Verify POL Instance ID And Locations Updated'
    * def isPoLineUpdated =
    """
    function(response) {
      return response.instanceId == instanceId &&
             response.instanceId != instanceIdOld &&
             response.locations != null &&
             response.locations.length == 2 &&
             response.locations[0].holdingId != holdingId1 &&
             response.locations[1].holdingId != holdingId1;
    }
    """
    Given path 'orders/order-lines', poLineId
    And retry until isPoLineUpdated(response)
    When method GET
    Then status 200

    # 6.2 Verify Instance #1 Now Has Three Holdings
    # (Precondition Holding In Loc1 + New Loc1 With Two Items + New Loc2 With One Item)
    * print '6.2 Verify Instance #1 Now Has Three Holdings'
    * configure headers = headersAdmin
    * def isInstanceHoldingsCreated =
    """
    function(response) {
      var ids = karate.jsonPath(response, '$.holdingsRecords[*].id');
      return response.totalRecords == 3 &&
             ids.indexOf(preconditionHoldingId) >= 0;
    }
    """
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    And retry until isInstanceHoldingsCreated(response)
    When method GET
    Then status 200

    # 6.3 Verify Old Instance No Longer Has Any Holdings
    * print '6.3 Verify Old Instance No Longer Has Any Holdings'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceIdOld
    And retry until response.totalRecords == 0
    When method GET
    Then status 200
