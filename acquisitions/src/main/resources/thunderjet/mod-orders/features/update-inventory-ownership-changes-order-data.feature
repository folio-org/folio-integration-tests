Feature: Update Item and Holding Ownership Changes Pieces and PoLine Data

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * call loginAdmin testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json' }
    * configure retry = { interval: 1000, count: 5 }

    * callonce variables

    ### Before Each ###
    # Inventory: instance, holding
    * def instanceId = call uuid
    * table instanceData
      | id         | title      | instanceTypeId       |
      | instanceId | instanceId | globalInstanceTypeId |
    * def v = call createInstance instanceData

    * def holdingId = call uuid
    * table holdingData
      | id        | instanceId | locationId        | sourceId               |
      | holdingId | instanceId | globalLocationsId | globalHoldingsSourceId |
    * def v = call createHolding holdingData

    # Orders: order, poline, piece
    * def orderId = call uuid
    * def v = call createOrder { id: '#(orderId)' }

    * def poLineId = call uuid
    * table poLineLocations
      | holdingId | quantity | quantityPhysical |
      | holdingId | 1        | 1                |
    * table orderLineData
      | id       | orderId | locations       | quantity | fundId       | instanceId | titleOrPackage        |
      | poLineId | orderId | poLineLocations | 1        | globalFundId | instanceId | 'TestOwnershipTitle1' |
    * def v = call createOrderLineWithInstance orderLineData

    * def v = call openOrder { orderId: '#(orderId)' }

    Given path 'orders/titles'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    * def titleId = response.titles[0].id


  Scenario: Test for changing ownership of Holdings to affect Pieces and PoLines
    # 1. Create new instance
    * def instanceId2 = call uuid
    * table instanceData
      | id          | title       | instanceTypeId       |
      | instanceId2 | instanceId2 | globalInstanceTypeId |
    * def v = call createInstance instanceData

    # 2.1 Move holding
    * table moveHoldingData
      | instanceId  | holdingId |
      | instanceId2 | holdingId |
    * def v = call moveHolding moveHoldingData

    # 2.2 Verify holding moved
    Given path 'holdings-storage/holdings', holdingId
    And retry until response.instanceId == instanceId2
    When method GET
    Then status 200

    # 3. Verify updated PoLine contains updated instanceId
    Given path 'orders/order-lines/', poLineId
    And retry until response.instanceId == instanceId2
    When method GET
    Then status 200

    # 4. Verify updated Title contains updated instanceId
    Given path 'orders/titles/', titleId
    And retry until response.instanceId == instanceId2
    When method GET
    Then status 200


  Scenario: Test for changing ownership of Item to affect Pieces
    # 1 Create a new piece
    * def pieceId = call uuid
    * table pieceData
      | id      | format     | poLineId | titleId | holdingId | createItem |
      | pieceId | "Physical" | poLineId | titleId | holdingId | true       |
    * def piece = call createPieceWithHolding pieceData
    * def itemId = piece[0].response.itemId

    # 2. Create new holding
    * def holdingId2 = call uuid
    * table holdingData
      | id         | instanceId  | locationId         | sourceId               |
      | holdingId2 | instanceId | globalLocationsId2 | globalHoldingsSourceId |
    * def v = call createHolding holdingData
    
    # 3.1 Move Item
    * table moveItemData
      | holdingId  | itemId |
      | holdingId2 | itemId |
    * def v = call moveItem moveItemData

    # 3.1 Verify Item moved
    Given path 'inventory/items/', itemId
    And retry until response.holdingsRecordId == holdingId2
    When method GET
    Then status 200

    # 4. Verify updated Piece contains updated holdingId
    Given path 'orders/pieces/', pieceId
    And retry until response.holdingId == holdingId2
    When method GET
    Then status 200