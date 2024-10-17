Feature: Update Item and Holding Ownership Changes Pieces and PoLine Data

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * call login consortiaAdmin
    * def headersCentral = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(centralTenant)' }
    * def headersUniversity = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(universityTenant)' }
    * configure headers = headersUniversity
    * configure retry = { interval: 1000, count: 5 }

    ### Before All ###
    * callonce variables
    * callonce variablesCentral
    * callonce variablesUniversity

    * def instanceId = callonce uuid
    * def randomNum = callonce randomMillis
    * def instanceHrid = "in" + randomNum
    * table instanceData
      | id         | title      | instanceTypeId           | hrid         |
      | instanceId | instanceId | universityInstanceTypeId | instanceHrid |
    * callonce createInstanceWithHrid instanceData

    * table shareInstanceData
      | instanceId | sourceTenantId   | targetTenantId | consortiumId |
      | instanceId | universityTenant | centralTenant  | consortiumId |
    * callonce shareInstance shareInstanceData


    ### Before Each ###
    # Inventory: holding
    * def holdingId = call uuid
    * table holdingData
      | id        | instanceId | locationId            | sourceId                   |
      | holdingId | instanceId | universityLocationsId | universityHoldingsSourceId |
    * def v = call createHolding holdingData

    # Orders: order, poline, piece, title
    * configure headers = headersCentral
    * def orderId = call uuid
    * def v = call createOrder { id: '#(orderId)' }

    * def poLineId = call uuid
    * table poLineLocations
      | holdingId            | quantity | quantityPhysical | tenantId         |
      | holdingId            | 1        | 1                | universityTenant |
      | universityHoldingId1 | 1        | 1                | universityTenant |
    * table orderLineData
      | id       | orderId | locations       | quantity | fundId        | instanceId | titleOrPackage |
      | poLineId | orderId | poLineLocations | 2        | centralFundId | instanceId | instanceId     |
    * def v = call createOrderLineWithInstance orderLineData

    * def v = call openOrder { orderId: '#(orderId)' }

    Given path 'orders/pieces'
    And param query = 'holdingId==' + holdingId
    When method GET
    Then status 200
    * def pieceId = response.pieces[0].id

    Given path 'orders/titles'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    * def titleId = response.titles[0].id

    * configure headers = headersUniversity
    Given path 'inventory/items-by-holdings-id'
    And param query = 'holdingsRecordId==' + holdingId
    When method GET
    Then status 200
    * def itemId = response.items[0].id


  Scenario: Test for changing ownership of Holdings to affect Pieces and PoLines
    # 1.1 Update holding ownership
    * table updateHoldingOwnershipData
      | instanceId | holdingId | targetTenantId | targetLocationId   |
      | instanceId | holdingId | centralTenant  | centralLocationsId |
    * def v = call updateHoldingOwnership updateHoldingOwnershipData

    # 1.2 Verify holding ownership
    * configure headers = headersCentral
    * table verifyOwnershipData
      | instanceId | holdingId | itemId | locationId            |
      | instanceId | holdingId | itemId | universityLocationsId |
    * def v = call verifyOwnership verifyOwnershipData

    # 2. Verify updated PoLine contains updated locations
    Given path 'orders/order-lines', poLineId
    And retry until response.locations[0].tenantId == centralTenant || response.locations[1].tenantId == centralTenant
    When method GET
    Then status 200
    And match response.locations[*].tenantId contains centralTenant
    And match response.locations[*].tenantId contains universityTenant
    And match response.locations[*].holdingId contains holdingId
    And match response.locations[*].holdingId contains universityHoldingId1

    # 3. Verify updated Piece contains updated receivingTenantId and holdingId
    Given path 'orders/pieces', pieceId
    And retry until response.receivingTenantId == centralTenant
    When method GET
    Then status 200
    And match response.holdingId == holdingId
    And match response.receivingTenantId == centralTenant


  Scenario: Test for changing ownership of Item to affect Pieces
    # 1. Create new holding in centralTenant
    * configure headers = headersCentral
    * def holdingIdCentral = call uuid
    * table holdingDataCentral
      | id               | instanceId | locationId         | sourceId                |
      | holdingIdCentral | instanceId | centralLocationsId | centralHoldingsSourceId |
    * def v = call createHolding holdingDataCentral

    # 2.1 Update Item ownership
    * configure headers = headersUniversity
    * table updateItemOwnershipData
      | holdingId        | itemId | targetTenantId |
      | holdingIdCentral | itemId | centralTenant  |
    * def v = call updateItemOwnership updateItemOwnershipData

    # 2.2 Verify Item ownership
    * table verifyOwnershipData
      | instanceId | holdingId        | itemId | locationId         |
      | instanceId | holdingIdCentral | itemId | centralLocationsId |
    * def v = call verifyOwnership verifyOwnershipData

    # 3. Verify updated Piece contains updated receivingTenantId and holdingId
    * configure headers = headersCentral
    Given path 'orders/pieces/', pieceId
    And retry until response.holdingId == holdingIdCentral
    When method GET
    Then status 200
    And match response.holdingId == holdingIdCentral
    And match response.receivingTenantId == centralTenant