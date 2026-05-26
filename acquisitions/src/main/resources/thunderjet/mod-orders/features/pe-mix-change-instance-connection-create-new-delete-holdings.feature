# For MODORDERS-1297, MODORDERS-1300, https://foliotest.testrail.io/index.php?/cases/view/784423
Feature: P/E Mix Change Instance Connection Create New Delete Holdings

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

  @C784423
  @Positive
  Scenario: P/E Mix Order Change Instance To Existing With Create New Holdings And Delete Abandoned Holdings
    * def instanceId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def preconditionHoldingId = call uuid

    # 1. Create Instance #1 With One Holding In Loc1 (Precondition)
    * print '1. Create Instance #1 With One Holding In Loc1 (Precondition)'
    * configure headers = headersAdmin
    * def v = call createInstance { id: '#(instanceId)', title: 'Instance C784423', instanceTypeId: '#(globalInstanceTypeId)' }

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

    # 2. Create P/E Mix Order And Open It
    * print '2. Create P/E Mix Order And Open It'
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
      titleOrPackage: 'Title C784423',
      orderFormat: 'P/E Mix',
      checkinItems: true,
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

    # 3.1 Get POL Holding IDs
    * print '3.1 Get POL Holding IDs'
    Given path 'orders/order-lines', poLineId
    And retry until response.locations[0].holdingId != null && response.locations[1].holdingId != null
    When method GET
    Then status 200
    * def holdingId1 = response.locations[0].holdingId
    * def holdingId2 = response.locations[1].holdingId
    * def instanceIdOld = response.instanceId

    # 3.2 Get Title ID
    * print '3.2 Get Title ID'
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.titles[0].poLineId == poLineId
    * def titleId = response.titles[0].id

    # 4.1 Create Pieces With Holding IDs
    * print '4.1 Create Pieces With Holding IDs'
    * def pieceId1 = call uuid
    * def pieceId2 = call uuid
    * table piecesData
      | id       | poLineId | titleId | holdingId  | format       | createItem |
      | pieceId1 | poLineId | titleId | holdingId1 | 'Physical'   | true       |
      | pieceId2 | poLineId | titleId | holdingId2 | 'Electronic' | true       |
    * def v = call createPieceWithHoldingOrLocation piecesData

    # 4.2 Create Piece #3 In New Location Loc3
    * print '4.2 Create Piece #3 In New Location Loc3'
    * def pieceId3 = call uuid
    * def pieceId3Data = { id: '#(pieceId3)', poLineId: '#(poLineId)', titleId: '#(titleId)', locationId: '#(globalLocationsId3)', useLocationId: true, format: 'Physical', createItem: true }
    * def v = call createPieceWithHoldingOrLocation pieceId3Data

    # 4.3 Get Holding ID Created For Piece #3
    * print '4.3 Get Holding ID Created For Piece #3'
    Given path 'orders/pieces', pieceId3
    When method GET
    Then status 200
    * def holdingId3 = response.holdingId

    # 4.4 Receive All Three Pieces
    * print '4.4 Receive All Three Pieces'
    * table receivePiecesData
      | pieceId  | poLineId | holdingId  |
      | pieceId1 | poLineId | holdingId1 |
      | pieceId2 | poLineId | holdingId2 |
      | pieceId3 | poLineId | holdingId3 |
    * def v = call receivePieceWithHolding receivePiecesData

    # 5. Change Instance Connection With "Create" Holdings Operation And Delete Abandoned Holdings
    * print '5. Change Instance Connection With "Create" Holdings Operation And Delete Abandoned Holdings'
    * table instanceChangeData
      | poLineId | instanceId | holdingsOperation | deleteAbandonedHoldings |
      | poLineId | instanceId | 'Create'          | true                    |
    * def v = call changeOrderLineInstanceConnection instanceChangeData

    # 6.1 Verify POL Instance ID And Holdings Updated
    * print '6.1 Verify POL Instance ID And Holdings Updated'
    * def isPoLineUpdated =
    """
    function(response) {
      return response.instanceId == instanceId &&
             response.instanceId != instanceIdOld &&
             response.locations != null &&
             response.locations.length == 2 &&
             response.locations[0].holdingId != holdingId1 &&
             response.locations[1].holdingId != holdingId2;
    }
    """
    Given path 'orders/order-lines', poLineId
    And retry until isPoLineUpdated(response)
    When method GET
    Then status 200
    * def newHoldingId1 = response.locations[0].holdingId
    * def newHoldingId2 = response.locations[1].holdingId

    # 6.2 Verify Instance #1 Now Has Four Holdings
    # (Precondition Holding In Loc1 + Three New Holdings Created For Loc1, Loc2, Loc3)
    * print '6.2 Verify Instance #1 Now Has Four Holdings'
    * configure headers = headersAdmin
    * def isInstanceHoldingsCreated =
    """
    function(response) {
      var ids = karate.jsonPath(response, '$.holdingsRecords[*].id');
      return response.totalRecords == 4 &&
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
