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

    # 1. Define Quantities For All Locations
    * print '1. Define Quantities For All Locations'
    * def order1Location1Qty = 3
    * def order1Location2Qty = 1
    * def order2Location1Qty = 2
    * def order2Location2Qty = 3
    * def order2Location3Qty = 1

    # 2. Create Fund And Budget
    * print '2. Create Fund And Budget'
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 10000, fundId: '#(fundId)', status: 'Active' }

    # 3. Create First Order With 2 Locations
    * print '3. Create First Order With 2 Locations'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(order1Id)' }
    * def order1TotalQty = order1Location1Qty + order1Location2Qty
    * def order1Locations =
    """
    [
      { locationId: '#(globalLocationsId)', quantityPhysical: '#(order1Location1Qty)', quantity: '#(order1Location1Qty)' },
      { locationId: '#(globalLocationsId2)', quantityPhysical: '#(order1Location2Qty)', quantity: '#(order1Location2Qty)' }
    ]
    """
    * call createOrderLine { id: '#(poLine1Id)', orderId: '#(order1Id)', fundId: '#(fundId)', locations: '#(order1Locations)', quantity: '#(order1TotalQty)' }

    # 4. Create Second Order With 3 Locations
    * print '4. Create Second Order With 3 Locations'
    * def v = call createOrder { id: '#(order2Id)' }
    * def order2TotalQty = order2Location1Qty + order2Location2Qty + order2Location3Qty
    * def order2Locations =
    """
    [
      { locationId: '#(globalLocationsId)', quantityPhysical: '#(order2Location1Qty)', quantity: '#(order2Location1Qty)' },
      { locationId: '#(globalLocationsId2)', quantityPhysical: '#(order2Location2Qty)', quantity: '#(order2Location2Qty)' },
      { locationId: '#(globalLocationsId3)', quantityPhysical: '#(order2Location3Qty)', quantity: '#(order2Location3Qty)' }
    ]
    """
    * call createOrderLine { id: '#(poLine2Id)', orderId: '#(order2Id)', fundId: '#(fundId)', locations: '#(order2Locations)', quantity: '#(order2TotalQty)' }

    # 5. Open First Order
    * print '5. Open First Order'
    * def v = call openOrder { orderId: '#(order1Id)' }

    # 6. Open Second Order
    * print '6. Open Second Order'
    * def v = call openOrder { orderId: '#(order2Id)' }

    # 7. Get Holdings From First Order Line
    * print '7. Get Holdings From First Order Line'
    Given path 'orders/order-lines', poLine1Id
    And retry until response.locations != null && response.locations.length == 2 && response.locations[0].holdingId != null && response.locations[1].holdingId != null
    When method GET
    Then status 200
    * def holding1Id = response.locations[0].holdingId
    * def holding2Id = response.locations[1].holdingId

    # 8. Get Holdings From Second Order Line
    * print '8. Get Holdings From Second Order Line'
    Given path 'orders/order-lines', poLine2Id
    And retry until response.locations != null && response.locations.length == 3 && response.locations[0].holdingId != null && response.locations[1].holdingId != null && response.locations[2].holdingId != null
    When method GET
    Then status 200
    * def holding3Id = response.locations[0].holdingId
    * def holding4Id = response.locations[1].holdingId
    * def holding5Id = response.locations[2].holdingId

    # 9. Prepare Holding Detail Request
    * print '9. Prepare Holding Detail Request'
    * def holdingDetailRequest = { holdingIds: ['#(holding1Id)', '#(holding2Id)', '#(holding3Id)', '#(holding4Id)', '#(holding5Id)'] }

    # 10. Call Holding Detail Endpoint
    * print '10. Call Holding Detail Endpoint'
    Given path 'orders/holding-detail'
    And request holdingDetailRequest
    When method POST
    Then status 200

    # 11. Verify Response Structure
    * print '11. Verify Response Structure'
    And match response == '#object'
    * def holding1Key = holding1Id + ''
    * def holding2Key = holding2Id + ''
    * def holding3Key = holding3Id + ''
    * def holding4Key = holding4Id + ''
    * def holding5Key = holding5Id + ''
    * def holding1Data = karate.get('response["' + holding1Key + '"]')
    * def holding2Data = karate.get('response["' + holding2Key + '"]')
    * def holding3Data = karate.get('response["' + holding3Key + '"]')
    * def holding4Data = karate.get('response["' + holding4Key + '"]')
    * def holding5Data = karate.get('response["' + holding5Key + '"]')
    And match holding1Data != null
    And match holding2Data != null
    And match holding3Data != null
    And match holding4Data != null
    And match holding5Data != null

    # 12. Verify Holding 1 Has Correct Number Of Pieces And Items Based On order1Location1Qty
    * print '12. Verify Holding 1 Has Correct Number Of Pieces And Items'
    And match holding1Data.pieces_detail_collection != null
    And match holding1Data.items_detail_collection != null
    And match holding1Data.pieces_detail_collection.pieces_detail == '#array'
    And match holding1Data.items_detail_collection.items_detail == '#array'
    * def holding1Pieces = holding1Data.pieces_detail_collection.pieces_detail
    * def holding1Items = holding1Data.items_detail_collection.items_detail
    And match each holding1Pieces contains { id: '#string', itemId: '#string' }
    And match each holding1Items contains { id: '#string' }
    And match karate.sizeOf(holding1Pieces) == order1Location1Qty
    And match karate.sizeOf(holding1Items) == order1Location1Qty
    And match holding1Data.pieces_detail_collection.totalRecords == order1Location1Qty
    And match holding1Data.items_detail_collection.totalRecords == order1Location1Qty

    # 13. Verify Piece Item IDs Match Item IDs In Items Collection For Holding 1
    * print '13. Verify Piece Item IDs Match Item IDs In Items Collection For Holding 1'
    * def holding1ItemIds = karate.map(holding1Items, function(item){ return item.id })
    * def holding1PieceItemIds = karate.map(holding1Pieces, function(piece){ return piece.itemId })
    And match holding1ItemIds contains only holding1PieceItemIds

    # 14. Verify Holding 2 Has Correct Number Of Pieces And Items Based On order1Location2Qty
    * print '14. Verify Holding 2 Has Correct Number Of Pieces And Items'
    And match holding2Data.pieces_detail_collection.pieces_detail == '#array'
    And match holding2Data.items_detail_collection.items_detail == '#array'
    * def holding2Pieces = holding2Data.pieces_detail_collection.pieces_detail
    * def holding2Items = holding2Data.items_detail_collection.items_detail
    And match each holding2Pieces contains { id: '#string', itemId: '#string' }
    And match each holding2Items contains { id: '#string' }
    And match karate.sizeOf(holding2Pieces) == order1Location2Qty
    And match karate.sizeOf(holding2Items) == order1Location2Qty
    And match holding2Data.pieces_detail_collection.totalRecords == order1Location2Qty
    And match holding2Data.items_detail_collection.totalRecords == order1Location2Qty

    # 15. Verify Holding 3 Has Correct Number Of Pieces And Items Based On order2Location1Qty
    * print '15. Verify Holding 3 Has Correct Number Of Pieces And Items'
    And match holding3Data.pieces_detail_collection.pieces_detail == '#array'
    And match holding3Data.items_detail_collection.items_detail == '#array'
    * def holding3Pieces = holding3Data.pieces_detail_collection.pieces_detail
    * def holding3Items = holding3Data.items_detail_collection.items_detail
    And match each holding3Pieces contains { id: '#string', itemId: '#string' }
    And match each holding3Items contains { id: '#string' }
    And match karate.sizeOf(holding3Pieces) == order2Location1Qty
    And match karate.sizeOf(holding3Items) == order2Location1Qty
    And match holding3Data.pieces_detail_collection.totalRecords == order2Location1Qty
    And match holding3Data.items_detail_collection.totalRecords == order2Location1Qty

    # 16. Verify Holding 4 Has Correct Number Of Pieces And Items Based On order2Location2Qty
    * print '16. Verify Holding 4 Has Correct Number Of Pieces And Items'
    And match holding4Data.pieces_detail_collection.pieces_detail == '#array'
    And match holding4Data.items_detail_collection.items_detail == '#array'
    * def holding4Pieces = holding4Data.pieces_detail_collection.pieces_detail
    * def holding4Items = holding4Data.items_detail_collection.items_detail
    And match each holding4Pieces contains { id: '#string', itemId: '#string' }
    And match each holding4Items contains { id: '#string' }
    And match karate.sizeOf(holding4Pieces) == order2Location2Qty
    And match karate.sizeOf(holding4Items) == order2Location2Qty
    And match holding4Data.pieces_detail_collection.totalRecords == order2Location2Qty
    And match holding4Data.items_detail_collection.totalRecords == order2Location2Qty

    # 17. Verify Holding 5 Has Correct Number Of Pieces And Items Based On order2Location3Qty
    * print '17. Verify Holding 5 Has Correct Number Of Pieces And Items'
    And match holding5Data.pieces_detail_collection.pieces_detail == '#array'
    And match holding5Data.items_detail_collection.items_detail == '#array'
    * def holding5Pieces = holding5Data.pieces_detail_collection.pieces_detail
    * def holding5Items = holding5Data.items_detail_collection.items_detail
    And match each holding5Pieces contains { id: '#string', itemId: '#string' }
    And match each holding5Items contains { id: '#string' }
    And match karate.sizeOf(holding5Pieces) == order2Location3Qty
    And match karate.sizeOf(holding5Items) == order2Location3Qty
    And match holding5Data.pieces_detail_collection.totalRecords == order2Location3Qty
    And match holding5Data.items_detail_collection.totalRecords == order2Location3Qty

  @Negative
  Scenario: Retrieve Holding Details With Empty Holding IDs Returns Empty Response
    # 1. Prepare Empty Holding Detail Request
    * print '1. Prepare Empty Holding Detail Request'
    * def emptyRequest = { holdingIds: [] }

    # 2. Call Holding Detail Endpoint With Empty Array
    * print '2. Call Holding Detail Endpoint With Empty Array'
    Given path 'orders/holding-detail'
    And request emptyRequest
    When method POST
    Then status 200

    # 3. Verify Response Is Empty Object
    * print '3. Verify Response Is Empty Object'
    And match response == {}

