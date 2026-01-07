# For MODORDERS-1371
Feature: Retrieve Holding Details With Pieces And Items

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

  @Positive
  Scenario: Retrieve Holding Details For Multiple Orders With Multiple Locations
    * def fundId = call uuid
    * def budgetId = call uuid
    * def order1Id = call uuid
    * def order2Id = call uuid
    * def poLine1Id = call uuid
    * def poLine2Id = call uuid

    # 1. Create Fund And Budget
    * print 'Create Fund And Budget'
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 10000, fundId: '#(fundId)', status: 'Active' }

    # 2. Create First Order With 2 Locations
    * print 'Create First Order With 2 Locations'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(order1Id)' }
    * def order1Locations =
    """
    [
      { locationId: '#(globalLocationsId)', quantityPhysical: 1, quantity: 1 },
      { locationId: '#(globalLocationsId2)', quantityPhysical: 1, quantity: 1 }
    ]
    """
    * call createOrderLine { id: '#(poLine1Id)', orderId: '#(order1Id)', fundId: '#(fundId)', locations: '#(order1Locations)', quantity: 2 }

    # 3. Create Second Order With 3 Locations
    * print 'Create Second Order With 3 Locations'
    * def v = call createOrder { id: '#(order2Id)' }
    * def order2Locations =
    """
    [
      { locationId: '#(globalLocationsId)', quantityPhysical: 1, quantity: 1 },
      { locationId: '#(globalLocationsId2)', quantityPhysical: 1, quantity: 1 },
      { locationId: '#(globalLocationsId3)', quantityPhysical: 1, quantity: 1 }
    ]
    """
    * call createOrderLine { id: '#(poLine2Id)', orderId: '#(order2Id)', fundId: '#(fundId)', locations: '#(order2Locations)', quantity: 3 }

    # 4. Open First Order
    * print 'Open First Order'
    * def v = call openOrder { orderId: '#(order1Id)' }

    # 5. Open Second Order
    * print 'Open Second Order'
    * def v = call openOrder { orderId: '#(order2Id)' }

    # 6. Get Holdings From First Order Line
    * print 'Get Holdings From First Order Line'
    Given path 'orders/order-lines', poLine1Id
    And retry until response.locations != null && response.locations.length == 2 && response.locations[0].holdingId != null && response.locations[1].holdingId != null
    When method GET
    Then status 200
    * def holding1Id = response.locations[0].holdingId
    * def holding2Id = response.locations[1].holdingId

    # 7. Get Holdings From Second Order Line
    * print 'Get Holdings From Second Order Line'
    Given path 'orders/order-lines', poLine2Id
    And retry until response.locations != null && response.locations.length == 3 && response.locations[0].holdingId != null && response.locations[1].holdingId != null && response.locations[2].holdingId != null
    When method GET
    Then status 200
    * def holding3Id = response.locations[0].holdingId
    * def holding4Id = response.locations[1].holdingId
    * def holding5Id = response.locations[2].holdingId

    # 8. Prepare Holding Detail Request
    * print 'Prepare Holding Detail Request'
    * def holdingDetailRequest = { holdingIds: ['#(holding1Id)', '#(holding2Id)', '#(holding3Id)', '#(holding4Id)', '#(holding5Id)'] }

    # 9. Call Holding Detail Endpoint
    * print 'Call Holding Detail Endpoint'
    Given path 'orders/holding-detail'
    And request holdingDetailRequest
    When method POST
    Then status 200

    # 10. Verify Response Structure
    * print 'Verify Response Structure'
    And match response == '#object'
    * def holding1Data = response[holding1Id]
    * def holding2Data = response[holding2Id]
    * def holding3Data = response[holding3Id]
    * def holding4Data = response[holding4Id]
    * def holding5Data = response[holding5Id]
    And match holding1Data == '#present'
    And match holding2Data == '#present'
    And match holding3Data == '#present'
    And match holding4Data == '#present'
    And match holding5Data == '#present'

    # 11. Verify Each Holding Has Pieces And Items Detail Collections
    * print 'Verify Each Holding Has Pieces And Items Detail Collections'
    And match holding1Data.pieces_detail_collection == '#present'
    And match holding1Data.items_detail_collection == '#present'
    And match holding1Data.pieces_detail_collection.pieces_detail == '#array'
    And match holding1Data.items_detail_collection.items_detail == '#array'
    And match holding1Data.pieces_detail_collection.totalRecords == '#number'
    And match holding1Data.items_detail_collection.totalRecords == '#number'

    # 12. Verify Pieces Have Expected Fields
    * print 'Verify Pieces Have Expected Fields'
    * def holding1Pieces = holding1Data.pieces_detail_collection.pieces_detail
    And match each holding1Pieces contains { id: '#string', itemId: '#string' }
    And match holding1Data.pieces_detail_collection.totalRecords == holding1Pieces.length

    # 13. Verify Items Have Expected Fields
    * print 'Verify Items Have Expected Fields'
    * def holding1Items = holding1Data.items_detail_collection.items_detail
    And match each holding1Items contains { id: '#string' }
    And match holding1Data.items_detail_collection.totalRecords == holding1Items.length

    # 14. Verify Piece Item IDs Match Item IDs In Items Collection
    * print 'Verify Piece Item IDs Match Item IDs In Items Collection'
    * def holding1ItemIds = karate.map(holding1Items, function(item){ return item.id })
    * def holding1PieceItemIds = karate.map(holding1Pieces, function(piece){ return piece.itemId })
    And match holding1ItemIds contains only holding1PieceItemIds

    # 15. Verify All Holdings Have Data
    * print 'Verify All Holdings Have Data'
    And match holding2Data.pieces_detail_collection.pieces_detail == '#array'
    And match holding2Data.items_detail_collection.items_detail == '#array'
    And match holding2Data.pieces_detail_collection.totalRecords == '#number'
    And match holding2Data.items_detail_collection.totalRecords == '#number'
    * def holding2Pieces = holding2Data.pieces_detail_collection.pieces_detail
    * def holding2Items = holding2Data.items_detail_collection.items_detail
    And match each holding2Pieces contains { id: '#string', itemId: '#string' }
    And match each holding2Items contains { id: '#string' }
    And match holding2Data.pieces_detail_collection.totalRecords == holding2Pieces.length
    And match holding2Data.items_detail_collection.totalRecords == holding2Items.length

    And match holding3Data.pieces_detail_collection.pieces_detail == '#array'
    And match holding3Data.items_detail_collection.items_detail == '#array'
    And match holding3Data.pieces_detail_collection.totalRecords == '#number'
    And match holding3Data.items_detail_collection.totalRecords == '#number'
    * def holding3Pieces = holding3Data.pieces_detail_collection.pieces_detail
    * def holding3Items = holding3Data.items_detail_collection.items_detail
    And match each holding3Pieces contains { id: '#string', itemId: '#string' }
    And match each holding3Items contains { id: '#string' }
    And match holding3Data.pieces_detail_collection.totalRecords == holding3Pieces.length
    And match holding3Data.items_detail_collection.totalRecords == holding3Items.length

    And match holding4Data.pieces_detail_collection.pieces_detail == '#array'
    And match holding4Data.items_detail_collection.items_detail == '#array'
    And match holding4Data.pieces_detail_collection.totalRecords == '#number'
    And match holding4Data.items_detail_collection.totalRecords == '#number'
    * def holding4Pieces = holding4Data.pieces_detail_collection.pieces_detail
    * def holding4Items = holding4Data.items_detail_collection.items_detail
    And match each holding4Pieces contains { id: '#string', itemId: '#string' }
    And match each holding4Items contains { id: '#string' }
    And match holding4Data.pieces_detail_collection.totalRecords == holding4Pieces.length
    And match holding4Data.items_detail_collection.totalRecords == holding4Items.length

    And match holding5Data.pieces_detail_collection.pieces_detail == '#array'
    And match holding5Data.items_detail_collection.items_detail == '#array'
    And match holding5Data.pieces_detail_collection.totalRecords == '#number'
    And match holding5Data.items_detail_collection.totalRecords == '#number'
    * def holding5Pieces = holding5Data.pieces_detail_collection.pieces_detail
    * def holding5Items = holding5Data.items_detail_collection.items_detail
    And match each holding5Pieces contains { id: '#string', itemId: '#string' }
    And match each holding5Items contains { id: '#string' }
    And match holding5Data.pieces_detail_collection.totalRecords == holding5Pieces.length
    And match holding5Data.items_detail_collection.totalRecords == holding5Items.length

  @Negative
  Scenario: Retrieve Holding Details With Empty Holding IDs Returns Empty Response
    # 1. Prepare Empty Holding Detail Request
    * print 'Prepare Empty Holding Detail Request'
    * def emptyRequest = { holdingIds: [] }

    # 2. Call Holding Detail Endpoint With Empty Array
    * print 'Call Holding Detail Endpoint With Empty Array'
    Given path 'orders/holding-detail'
    And request emptyRequest
    When method POST
    Then status 200

    # 3. Verify Response Is Empty Object
    * print 'Verify Response Is Empty Object'
    And match response == {}

