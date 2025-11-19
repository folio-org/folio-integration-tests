@parallel=false
Feature: Move Item and Holding to update order data

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }

    * configure retry = { interval: 10000, count: 10 }

    * callonce variables

  @Positive
  Scenario: Test for changing ownership of Holdings to affect Pieces and PoLines
    * configure headers = headersAdmin
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

    # Finance: budget, fund
    * def fundId = call uuid
    * def budgetId = call uuid
    * def v = call createFund { 'id': '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 100, 'fundId': '#(fundId)' }

    # Orders: order, poline, piece
    * configure headers = headersUser
    * def orderId = call uuid
    * def v = call createOrder { id: '#(orderId)' }

    * def poLineId = call uuid
    * table poLineLocations
      | holdingId | quantity | quantityPhysical |
      | holdingId | 1        | 1                |
    * table orderLineData
      | id       | orderId | locations       | quantity | fundId | instanceId | titleOrPackage        |
      | poLineId | orderId | poLineLocations | 1        | fundId | instanceId | 'TestOwnershipTitle1' |
    * def v = call createOrderLineWithInstance orderLineData

    * def v = call openOrder { orderId: '#(orderId)' }

    Given path 'orders/titles'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    * def titleId = response.titles[0].id

    # 1. Create new instance
    * configure headers = headersAdmin
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
    * configure headers = headersUser
    Given path 'orders/order-lines/', poLineId
    And retry until response.instanceId == instanceId2
    When method GET
    Then status 200

    # 4. Verify updated Title contains updated instanceId
    Given path 'orders/titles/', titleId
    And retry until response.instanceId == instanceId2
    When method GET
    Then status 200

    # 5. Unopen orders with delete holdings
    * def v = call unopenOrderDeleteHoldings { "orderId": "#(orderId)" }

    # 6. Delete instance to avoid the instance being used by the next test
    * def v = call deleteInstance { "id": "#(instanceId)" }
    * def v = call deleteInstance { "id": "#(instanceId2)" }

  @Positive
  Scenario: Test for changing ownership of Item to affect Pieces
    * configure headers = headersAdmin
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

    # Finance: budget, fund
    * def fundId = call uuid
    * def budgetId = call uuid
    * def v = call createFund { 'id': '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 100, 'fundId': '#(fundId)' }

    # Orders: order, poline, piece
    * configure headers = headersUser
    * def orderId = call uuid
    * def v = call createOrder { id: '#(orderId)' }

    * def poLineId = call uuid
    * table poLineLocations
      | holdingId | quantity | quantityPhysical |
      | holdingId | 1        | 1                |
    * table orderLineData
      | id       | orderId | locations       | quantity | fundId | instanceId | titleOrPackage        |
      | poLineId | orderId | poLineLocations | 1        | fundId | instanceId | 'TestOwnershipTitle1' |
    * def v = call createOrderLineWithInstance orderLineData

    * def v = call openOrder { orderId: '#(orderId)' }

    Given path 'orders/titles'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    * def titleId = response.titles[0].id

    # 1 Create a new piece
    * def pieceId = call uuid
    * table pieceData
      | id      | format     | poLineId | titleId | holdingId | createItem |
      | pieceId | "Physical" | poLineId | titleId | holdingId | true       |
    * def piece = call createPieceWithHoldingOrLocation pieceData
    * def itemId = piece[0].response.itemId

    # 2. Create new holding
    * configure headers = headersAdmin
    * def holdingId2 = call uuid
    * table holdingData
      | id         | instanceId | locationId         | sourceId               |
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
    * configure headers = headersUser
    Given path 'orders/pieces/', pieceId
    And retry until response.holdingId == holdingId2
    When method GET
    Then status 200

    # 5. Unopen orders with delete holdings
    * def v = call unopenOrderDeleteHoldings { "orderId": "#(orderId)" }

    # 6. Delete instance to avoid the instance being used by the next test
    * def v = call deleteInstance { "id": "#(instanceId)" }