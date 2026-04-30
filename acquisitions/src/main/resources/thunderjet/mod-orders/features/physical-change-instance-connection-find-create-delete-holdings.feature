# For MODORDERS-1297, https://foliotest.testrail.io/index.php?/cases/view/784421
Feature: Physical Independent Change Instance Connection Find Or Create New Delete Holdings

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

  @C784421
  @Positive
  Scenario: Physical Order With Independent Workflow Change Instance Connection Find Or Create New And Delete Holdings After Receiving Piece In New Location
    * def instanceId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def pieceId = call uuid

    # 1. Create Target Instance #1 Without Holdings (Precondition)
    * print '1. Create Target Instance #1 Without Holdings (Precondition)'
    * configure headers = headersAdmin
    * def v = call createInstance { id: '#(instanceId)', title: 'Instance C784421', instanceTypeId: '#(globalInstanceTypeId)' }

    # 2. Create Physical Order With Independent Receiving Workflow And Open It
    * print '2. Create Physical Order With Independent Receiving Workflow And Open It'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }
    * table locations
      | locationId            | quantity | quantityPhysical |
      | globalLocationsId     | 1        | 1                |

    * def orderLineRequest =
    """
    {
      id: '#(poLineId)',
      orderId: '#(orderId)',
      titleOrPackage: 'Title C784421',
      orderFormat: 'Physical Resource',
      checkinItems: true,
      createInventory: 'Instance, Holding, Item',
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

    # 3.2 Get Title ID
    * print '3.2 Get Title ID'
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleId = $.titles[0].id

    # 4.1 Add Piece In New Location Loc2 (Independent Workflow - "Create Item" Active)
    * print '4.1 Add Piece In New Location Loc2 (Independent Workflow - "Create Item" Active)'
    * def pieceRequest =
    """
    { id: '#(pieceId)', poLineId: '#(poLineId)', titleId: '#(titleId)', locationId: '#(globalLocationsId2)', useLocationId: true, format: 'Physical', createItem: true }
    """
    * def v = call createPieceWithHoldingOrLocation pieceRequest

    # 4.2 Get Holding ID Created For Piece In Loc2
    * print '4.2 Get Holding ID Created For Piece In Loc2'
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    * def holdingId2 = response.holdingId
    And match holdingId2 != holdingId1

    # 4.3 Receive The Piece In Loc2
    * print '4.3 Receive The Piece In Loc2'
    * table receivePiecesData
      | pieceId | poLineId | holdingId  |
      | pieceId | poLineId | holdingId2 |
    * def v = call receivePieceWithHolding receivePiecesData

    # 5. Change Instance Connection To Instance #1 With "Find Or Create" And Delete Abandoned Holdings
    * print '5. Change Instance Connection To Instance #1 With "Find Or Create" And Delete Abandoned Holdings'
    * table instanceChangeData
      | poLineId | instanceId | holdingsOperation | deleteAbandonedHoldings |
      | poLineId | instanceId | 'Find or Create'  | true                    |
    * def v = call changeOrderLineInstanceConnection instanceChangeData

    # 6.1 Verify POL Instance ID And Holdings Updated To Point To Instance #1
    * print '6.1 Verify POL Instance ID And Holdings Updated To Point To Instance #1'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.instanceId == instanceId
    And match response.instanceId != instanceIdOld
    And match response.locations[*].holdingId !contains holdingId1
    And match response.locations[*].holdingId !contains holdingId2

    # 6.2 Verify Instance #1 Now Has Two Holdings (Loc1 From POL + Loc2 From Received Piece)
    * print '6.2 Verify Instance #1 Now Has Two Holdings (Loc1 From POL + Loc2 From Received Piece)'
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200
    And match response.holdingsRecords[*].permanentLocationId contains globalLocationsId
    And match response.holdingsRecords[*].permanentLocationId contains globalLocationsId2

    # 6.3 Verify Old Instance No Longer Has Any Holdings (Abandoned Holdings Deleted)
    * print '6.3 Verify Old Instance No Longer Has Any Holdings (Abandoned Holdings Deleted)'
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceIdOld
    And retry until response.totalRecords == 0
    When method GET
    Then status 200

