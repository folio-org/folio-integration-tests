# For: MODORDERS-1241
Feature: Received pieces are counted when reopening previously unopened synchronized order

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * call eurekaLogin { username: '#(consortiaAdmin.username)', password: '#(consortiaAdmin.password)', tenant: '#(centralTenantName)' }
    * def headersCentral = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': 'application/json' }
    * def headersUni = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(universityTenantName)', 'Accept': 'application/json' }
    * configure headers = headersCentral

    * configure retry = { interval: 5000, count: 10 }

    * callonce variables
    * callonce variablesCentral
    * callonce variablesUniversity

    * def fundId = call uuid
    * def budgetId = call uuid
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }

  @Positive
  Scenario: Reopen previously unopened synchronized order with already received piece does not create extra expected pieces
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Create order in Central tenant
    * def v = call createOrder { id: '#(orderId)', vendor: '#(centralVendorId)' }

    # 2. Create PO line
    * def memberLocations = [ { locationId: '#(universityLocationsId)', tenantId: '#(universityTenantName)', quantity: 2, quantityPhysical: 2 } ]
    * table poLineData
      | id       | orderId | fundId | quantity | locations       | checkinItems | createInventory           |
      | poLineId | orderId | fundId | 2        | memberLocations | false        | 'Instance, Holding, Item' |
    * def v = call createOrderLine poLineData

    # 3. Open the order - synchronized workflow creates 2 expected pieces
    * def v = call openOrder { orderId: '#(orderId)' }

    # 4. Verify 2 expected pieces are created with member tenant as receivingTenantId
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200
    And match response.pieces[*].receivingStatus == [ 'Expected', 'Expected' ]
    And match response.pieces[*].receivingTenantId == [ '#(universityTenantName)', '#(universityTenantName)' ]
    * def pieceToReceive = response.pieces[0]
    * def pieceToReceiveId = pieceToReceive.id
    * def pieceHoldingId = pieceToReceive.holdingId

    # 5. Receive one piece
    * def v = call receivePieceWithHolding { pieceId: '#(pieceToReceiveId)', poLineId: '#(poLineId)', holdingId: '#(pieceHoldingId)', tenantId: '#(universityTenantName)' }

    # 6. Verify the piece moved to Received status, and the other one stays Expected
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId + ' and receivingStatus==Received'
    And retry until response.totalRecords == 1
    When method GET
    Then status 200

    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId + ' and receivingStatus==Expected'
    And retry until response.totalRecords == 1
    When method GET
    Then status 200

    # 7. Unopen the order with delete holdings/items - expected piece's holding/item are deleted, received piece is preserved
    * def v = call unopenOrder { orderId: '#(orderId)', deleteHoldings: true }

    # 8. Verify only the received piece remains
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    And retry until response.totalRecords == 1 && response.pieces[0].receivingStatus == 'Received'
    When method GET
    Then status 200

    # 9. Reopen the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 10. Verify total pieces match POL quantity (2): 1 already-received + 1 newly-created expected
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200
    And match response.pieces[*].receivingStatus contains 'Received'
    And match response.pieces[*].receivingStatus contains 'Expected'

    # 11. Verify number of items in Member-1 tenant matches POL quantity (2)
    * configure headers = headersUni
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    And retry until response.totalRecords == 2
    When method GET
    Then status 200
