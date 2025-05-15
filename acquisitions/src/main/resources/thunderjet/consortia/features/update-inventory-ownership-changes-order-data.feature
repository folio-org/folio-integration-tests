Feature: Updating Holding ownership changes order data

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * def headersCentral = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(centralTenantName)' }
    * def headersUniversity = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json', 'x-okapi-tenant': '#(universityTenantName)' }
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
      | instanceId | sourceTenantId       | targetTenantId     | consortiumId |
      | instanceId | universityTenantName | centralTenantName  | consortiumId |
    * callonce shareInstance shareInstanceData


    ### Before Each ###
    * def holdingId = call uuid
    * table holdingData
      | id        | instanceId | locationId            | sourceId                   |
      | holdingId | instanceId | universityLocationsId | universityHoldingsSourceId |
    * def v = call createHolding holdingData

    * configure headers = headersCentral
    * def orderId = call uuid
    * def v = call createOrder { id: '#(orderId)' }

    * def poLineId = call uuid
    * table poLineLocations
      | holdingId            | quantity | quantityPhysical | tenantId             |
      | holdingId            | 1        | 1                | universityTenantName |
      | universityHoldingId1 | 1        | 1                | universityTenantName |
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


  @Positive
  Scenario: Test for changing ownership of Holdings to affect Pieces and PoLines
    # 1.1 Update holding ownership
    * table updateHoldingOwnershipData
      | instanceId | holdingId | targetTenantId     | targetLocationId   |
      | instanceId | holdingId | centralTenantName  | centralLocationsId |
    * def v = call updateHoldingOwnership updateHoldingOwnershipData

    # 1.2 Verify holding ownership
    * configure headers = headersCentral
    * table verifyOwnershipData
      | instanceId | holdingId | itemId | locationId         |
      | instanceId | holdingId | itemId | centralLocationsId |
    * def v = call verifyOwnership verifyOwnershipData

    # 2. Verify updated PoLine contains updated locations
    Given path 'orders/order-lines', poLineId
    And retry until response.locations[0].tenantId == centralTenantName || response.locations[1].tenantId == centralTenantName
    When method GET
    Then status 200
    And match response.locations[*].tenantId contains centralTenantName
    And match response.locations[*].tenantId contains universityTenantName
    And match response.locations[*].holdingId contains holdingId
    And match response.locations[*].holdingId contains universityHoldingId1

    # 3. Verify updated Piece contains updated receivingTenantId and holdingId
    Given path 'orders/pieces', pieceId
    And retry until response.receivingTenantId == centralTenantName
    When method GET
    Then status 200
    And match response.holdingId == holdingId
    And match response.receivingTenantId == centralTenantName