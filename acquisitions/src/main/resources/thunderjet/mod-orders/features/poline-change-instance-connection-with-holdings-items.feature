Feature: Change order line instance connection with holdings items

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

    * def createAndOpenOrderWithPEMixPoLine = read('classpath:thunderjet/mod-orders/helpers/helper-poline-change-instance-connection-with-holdings-items.feature@CreateAndOpenOrderWithPEMixPoLine')

    * callonce variables
    * def fundId = globalFundId

  Scenario: Change instance connection with "Create" and then "Find or Create" holdings operations
    # 1. Create instance
    * configure headers = headersAdmin
    * def instanceId = call uuid
    * def v = call createInstance { id: '#(instanceId)', title: 'i1', instanceTypeId: '#(globalInstanceTypeId)' }
    * configure headers = headersUser

    # 2. Create order and order line, then open the order
    * def orderId = call uuid
    * def poLineId = call uuid
    * def v = call createAndOpenOrderWithPEMixPoLine { poLineId: '#(poLineId)', orderId: '#(orderId)', title: 't1', checkinItems: true }

    # 3.1 Get POL holding IDs and POL number
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def holdingId1 = response.locations[0].holdingId
    * def holdingId2 = response.locations[1].holdingId
    * def poLineNumber = response.poLineNumber
    * def instanceIdOld = response.instanceId

    # 3.2 Get Title ID
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.titles[0].poLineId == poLineId
    * def titleId = response.titles[0].id

    # 4.1 Create pieces with holding IDs
    * def pieceId1 = call uuid
    * def pieceId2 = call uuid
    * table piecesData
      | id       | poLineId | titleId | holdingId  | format       | createItem |
      | pieceId1 | poLineId | titleId | holdingId1 | 'Physical'   | true       |
      | pieceId2 | poLineId | titleId | holdingId2 | 'Electronic' | true       |
    * def v = call createPieceWithHoldingOrLocation piecesData

    # 4.2 Receive pieces
    * table receivePiecesData
      | pieceId  | poLineId | holdingId  |
      | pieceId1 | poLineId | holdingId1 |
      | pieceId2 | poLineId | holdingId2 |
    * def v = call receivePieceWithHolding receivePiecesData

    # 5. Change instance connection with "Create" holdings operation to the new instance and do not delete abandoned holdings
    * table instanceChangeData
      | poLineId | instanceId | holdingsOperation | deleteAbandonedHoldings |
      | poLineId | instanceId | 'Create'          | false                   |
    * def v = call changeOrderLineInstanceConnection instanceChangeData

    # 6.1 Verify the order line instanceId and holdings
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.instanceId == instanceId
    And match response.instanceId != instanceIdOld
    And match response.locations[*].holdingId !contains holdingId1
    And match response.locations[*].holdingId !contains holdingId2
    * def newHoldingId1 = response.locations[0].holdingId
    * def newHoldingId2 = response.locations[1].holdingId

    # 6.2 Verify old instance holdings are not deleted
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceIdOld
    When method GET
    Then status 200
    And match response.totalRecords == 2
    And match response.holdingsRecords[*].id contains holdingId1
    And match response.holdingsRecords[*].id contains holdingId2

    # 6.3 Verify the new instance holdings are created
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match response.totalRecords == 2
    And match response.holdingsRecords[*].id contains newHoldingId1
    And match response.holdingsRecords[*].id contains newHoldingId2
    * configure headers = headersUser

    # 7. Change instance connection with "Find or Create" holdings operation to the old new instance and delete abandoned holdings
    * table instanceChangeData
      | poLineId | instanceId    | holdingsOperation | deleteAbandonedHoldings |
      | poLineId | instanceIdOld | 'Find or Create'  | true                    |
    * def v = call changeOrderLineInstanceConnection instanceChangeData

    # 8.1 Verify the order line instanceId and holdings
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.instanceId == instanceIdOld
    And match response.instanceId != instanceId
    And match response.locations[*].holdingId !contains newHoldingId1
    And match response.locations[*].holdingId !contains newHoldingId2
    And match response.locations[*].holdingId contains holdingId1
    And match response.locations[*].holdingId contains holdingId2

    # 8.2 Verify the new instance holdings are deleted
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # 8.3 Verify the old instance holdings are still present and no new holdings are created
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceIdOld
    When method GET
    Then status 200
    And match response.totalRecords == 2
    And match response.holdingsRecords[*].id contains holdingId1
    And match response.holdingsRecords[*].id contains holdingId2
    * configure headers = headersUser

  Scenario: Change instance connection with different holdings for Pieces and POL Locations
    # 1. Create instance
    * configure headers = headersAdmin
    * def instanceId = call uuid
    * def v = call createInstance { id: '#(instanceId)', title: 'i2', instanceTypeId: '#(globalInstanceTypeId)' }
    * configure headers = headersUser

    # 2. Create order and order line, then open the order
    * def orderId = call uuid
    * def poLineId = call uuid
    * def v = call createAndOpenOrderWithPEMixPoLine { poLineId: '#(poLineId)', orderId: '#(orderId)', title: 't2', checkinItems: true }

    # 3.1 Get POL holding IDs and POL number
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def holdingId1 = response.locations[0].holdingId
    * def holdingId2 = response.locations[1].holdingId
    * def poLineNumber = response.poLineNumber
    * def instanceIdOld = response.instanceId

    # 3.2 Get Title ID
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.titles[0].poLineId == poLineId
    * def titleId = response.titles[0].id

    # 4.1 Create piece with a different location
    * def pieceId = call uuid
    * table piecesData
      | id      | poLineId | titleId | locationId         | useLocationId | format     | createItem |
      | pieceId | poLineId | titleId | globalLocationsId3 | true          | 'Physical' | true       |
    * def v = call createPieceWithHoldingOrLocation piecesData

    # 4.2 Get holding ID from the created piece
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    * def holdingIdPiece = response.holdingId

    # 4.3 Receive pieces
    * table receivePiecesData
      | pieceId | poLineId | holdingId      |
      | pieceId | poLineId | holdingIdPiece |
    * def v = call receivePieceWithHolding receivePiecesData

    # 5. Change instance connection with "Create" holdings operation to the new instance and delete abandoned holdings
    * table instanceChangeData
      | poLineId | instanceId | holdingsOperation | deleteAbandonedHoldings |
      | poLineId | instanceId | 'Create'          | true                    |
    * def v = call changeOrderLineInstanceConnection instanceChangeData

    # 6.1 Verify the order line instanceId and holdings
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match response.instanceId == instanceId
    And match response.instanceId != instanceIdOld
    And match response.locations[*].holdingId !contains holdingId1
    And match response.locations[*].holdingId !contains holdingId2
    * def newHoldingId1 = response.locations[0].holdingId
    * def newHoldingId2 = response.locations[1].holdingId

    # 6.2 Verify old instance holdings are deleted
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceIdOld
    When method GET
    Then status 200
    And match response.totalRecords == 0

    # 6.3 Verify the new instance holdings are created
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match response.totalRecords == 3
    And match response.holdingsRecords[*].id contains newHoldingId1
    And match response.holdingsRecords[*].id contains newHoldingId2
    * configure headers = headersUser
