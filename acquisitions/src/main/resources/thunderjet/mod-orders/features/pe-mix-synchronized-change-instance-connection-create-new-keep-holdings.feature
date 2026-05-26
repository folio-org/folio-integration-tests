# For MODORDERS-1300, MODORDSTOR-490, https://foliotest.testrail.io/index.php?/cases/view/784424
Feature: P/E Mix Synchronized Change Instance Connection Create New Keep Holdings

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

  @C784424
  @Positive
  Scenario: P/E Mix Order Synchronized Change Instance To Existing With Create New Holdings And Keep Abandoned Holdings
    * def instanceId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def pieceId3 = call uuid

    # 1. Create Instance #1 Without Holdings (Precondition)
    * print '1. Create Instance #1 Without Holdings (Precondition)'
    * configure headers = headersAdmin
    * def v = call createInstance { id: '#(instanceId)', title: 'Instance C784424', instanceTypeId: '#(globalInstanceTypeId)' }

    # 2. Create P/E Mix Order With Synchronized Workflow And Open It
    * print '2. Create P/E Mix Order With Synchronized Workflow And Open It'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }
    * def locations =
    """
    [
      { locationId: '#(globalLocationsId)', quantity: 1, quantityPhysical: 1 },
      { locationId: '#(globalLocationsId2)', quantity: 1, quantityElectronic: 1 }
    ]
    """

    * def orderLineRequest =
    """
    {
      id: '#(poLineId)',
      orderId: '#(orderId)',
      titleOrPackage: 'Title C784424',
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

    # 3.1 Get POL Instance ID And Auto-Created Holding IDs
    * print '3.1 Get POL Instance ID And Auto-Created Holding IDs'
    Given path 'orders/order-lines', poLineId
    And retry until response.instanceId != null && response.locations[0].holdingId != null && response.locations[1].holdingId != null
    When method GET
    * def instanceIdOld = response.instanceId
    * def holdingId1 = response.locations[0].holdingId
    * def holdingId2 = response.locations[1].holdingId

    # 3.2 Get Title ID And Auto-Created Pieces
    * print '3.2 Get Title ID And Auto-Created Pieces'
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    * def titleId = response.titles[0].id

    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    And retry until response.totalRecords == 2
    When method GET
    * def physicalPieceId = karate.filter(response.pieces, function(p) { return p.format == 'Physical' })[0].id
    * def electronicPieceId = karate.filter(response.pieces, function(p) { return p.format == 'Electronic' })[0].id

    # 4.1 Add Piece In New Location Loc3
    * print '4.1 Add Piece In New Location Loc3'
    * def pieceRequest = { id: '#(pieceId3)', poLineId: '#(poLineId)', titleId: '#(titleId)', locationId: '#(globalLocationsId3)', useLocationId: true, format: 'Physical', createItem: true }
    * def v = call createPieceWithHoldingOrLocation pieceRequest

    # 4.2 Get Holding ID Created For Piece In Loc3
    * print '4.2 Get Holding ID Created For Piece In Loc3'
    Given path 'orders/pieces', pieceId3
    When method GET
    Then status 200
    * def holdingId3 = response.holdingId

    # 4.3 Receive All Pieces
    * print '4.3 Receive All Pieces'
    * table receivePiecesData
      | pieceId           | poLineId | holdingId  |
      | physicalPieceId   | poLineId | holdingId1 |
      | electronicPieceId | poLineId | holdingId2 |
      | pieceId3          | poLineId | holdingId3 |
    * def v = call receivePieceWithHolding receivePiecesData

    # 5. Change Instance Connection With "Create" Holdings Operation And Keep Abandoned Holdings
    * print '5. Change Instance Connection With "Create" Holdings Operation And Keep Abandoned Holdings'
    * table instanceChangeData
      | poLineId | instanceId | holdingsOperation | deleteAbandonedHoldings |
      | poLineId | instanceId | 'Create'          | false                   |
    * def v = call changeOrderLineInstanceConnection instanceChangeData

    # 6.1 Verify POL Instance ID And Locations Updated
    * print '6.1 Verify POL Instance ID And Locations Updated'
    * def isPoLineUpdated =
    """
    function(response) {
      return response.instanceId == instanceId &&
             response.instanceId != instanceIdOld &&
             response.locations != null &&
             response.locations.length == 3 &&
             response.locations[0].holdingId != holdingId1 &&
             response.locations[1].holdingId != holdingId2;
    }
    """
    Given path 'orders/order-lines', poLineId
    And retry until isPoLineUpdated(response)
    When method GET

    # 6.2 Verify Instance #1 Now Has Three Holdings (Loc1, Loc2, Loc3)
    * print '6.2 Verify Instance #1 Now Has Three Holdings'
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    And retry until response.totalRecords == 3
    When method GET

    # 6.3 Verify Old Instance Still Retains Its Holdings
    * print '6.3 Verify Old Instance Still Retains Its Holdings'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceIdOld
    And retry until response.totalRecords == 3
    When method GET

