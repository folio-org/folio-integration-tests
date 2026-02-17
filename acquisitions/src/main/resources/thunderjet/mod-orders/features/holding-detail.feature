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

    # 12. Verify All Holdings Have Correct Number Of Pieces And Items Using Table
    * print '12. Verify All Holdings Have Correct Number Of Pieces And Items Using Table'
    * def holdingsTable =
    """
    [
      { holdingData: '#(holding1Data)', expectedQty: '#(order1Location1Qty)', expectedPoLineId: '#(poLine1Id)', holdingName: 'Holding 1' },
      { holdingData: '#(holding2Data)', expectedQty: '#(order1Location2Qty)', expectedPoLineId: '#(poLine1Id)', holdingName: 'Holding 2' },
      { holdingData: '#(holding3Data)', expectedQty: '#(order2Location1Qty)', expectedPoLineId: '#(poLine2Id)', holdingName: 'Holding 3' },
      { holdingData: '#(holding4Data)', expectedQty: '#(order2Location2Qty)', expectedPoLineId: '#(poLine2Id)', holdingName: 'Holding 4' },
      { holdingData: '#(holding5Data)', expectedQty: '#(order2Location3Qty)', expectedPoLineId: '#(poLine2Id)', holdingName: 'Holding 5' }
    ]
    """
    * def verifyHolding =
    """
    function(holding) {
      var data = holding.holdingData;
      var expected = holding.expectedQty;
      var expectedPoLineId = holding.expectedPoLineId;
      var name = holding.holdingName;

      karate.log('Verifying ' + name + ' with expected quantity: ' + expected);

      // Verify collections exist
      karate.match(data.poLines_detail_collection, '!= null');
      karate.match(data.pieces_detail_collection, '!= null');
      karate.match(data.items_detail_collection, '!= null');
      karate.match(data.poLines_detail_collection.poLines_detail, '#array');
      karate.match(data.pieces_detail_collection.pieces_detail, '#array');
      karate.match(data.items_detail_collection.items_detail, '#array');

      // Extract and verify each poLine structure
      karate.match(data.poLines_detail_collection.poLines_detail.length, 1);
      karate.match(data.poLines_detail_collection.poLines_detail[0].id, expectedPoLineId);
      karate.match(data.poLines_detail_collection.totalRecords, 1);

      // Extract pieces and items
      var pieces = data.pieces_detail_collection.pieces_detail;
      var items = data.items_detail_collection.items_detail;

      // Verify each piece and item structure
      for (var i = 0; i < pieces.length; i++) {
        karate.match(pieces[i].id, '#string');
        karate.match(pieces[i].itemId, '#string');
        karate.match(pieces[i].poLineId, expectedPoLineId);
      }
      for (var i = 0; i < items.length; i++) {
        karate.match(items[i].id, '#string');
      }

      // Verify sizes
      karate.match(pieces.length, expected);
      karate.match(items.length, expected);
      karate.match(data.pieces_detail_collection.totalRecords, expected);
      karate.match(data.items_detail_collection.totalRecords, expected);

      // Verify piece itemIds match item ids
      var itemIds = karate.map(items, function(item){ return item.id });
      var pieceItemIds = karate.map(pieces, function(piece){ return piece.itemId });
      itemIds.sort();
      pieceItemIds.sort();
      karate.match(itemIds, pieceItemIds);

      return true;
    }
    """
    * karate.forEach(holdingsTable, verifyHolding)

  @Positive
  Scenario: Retrieve Holding Details For Two Orders With Same Holding And One Order With Another But All Opened With Create Inventory None
    * def fundId = call uuid
    * def budgetId = call uuid
    * def order1Id = call uuid
    * def order2Id = call uuid
    * def order3Id = call uuid
    * def poLine1Id = call uuid
    * def poLine2Id = call uuid
    * def poLine3Id = call uuid
    * def instanceId = call uuid
    * def holdingId = call uuid
    * def holdingId2 = call uuid

    # 1. Create Fund And Budget
    * print '1. Create Fund And Budget'
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 10000, fundId: '#(fundId)', status: 'Active' }

    # 2. Create Instance
    * print '2. Create Instance'
    * def v = call createInstance { id: '#(instanceId)', title: 'Test Instance', instanceTypeId: '#(globalInstanceTypeId)' }

    # 3. Create First Holding
    * print '3. Create First Holding'
    * def v = call createHolding { id: '#(holdingId)', instanceId: '#(instanceId)', locationId: '#(globalLocationsId)', sourceId: '#(globalHoldingsSourceId)' }

    # 4. Create Second Holding
    * print '4. Create Second Holding'
    * def v = call createHolding { id: '#(holdingId2)', instanceId: '#(instanceId)', locationId: '#(globalLocationsId2)', sourceId: '#(globalHoldingsSourceId)' }

    # 5. Create First Order
    * print '5. Create First Order'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(order1Id)' }

    # 6. Create First Order Line With Create Inventory None And First Holding ID
    * print '6. Create First Order Line With Create Inventory None And First Holding ID'
    * def order1Locations = [{ holdingId: '#(holdingId)', quantityPhysical: 2, quantity: 2 }]
    * call createOrderLine { id: '#(poLine1Id)', orderId: '#(order1Id)', fundId: '#(fundId)', locations: '#(order1Locations)', quantity: 2, createInventory: 'None' }

    # 7. Create Second Order
    * print '7. Create Second Order'
    * def v = call createOrder { id: '#(order2Id)' }

    # 8. Create Second Order Line With Create Inventory None And Same First Holding ID
    * print '8. Create Second Order Line With Create Inventory None And Same First Holding ID'
    * def order2Locations = [{ holdingId: '#(holdingId)', quantityPhysical: 3, quantity: 3 }]
    * call createOrderLine { id: '#(poLine2Id)', orderId: '#(order2Id)', fundId: '#(fundId)', locations: '#(order2Locations)', quantity: 3, createInventory: 'None' }

    # 9. Create Third Order
    * print '9. Create Third Order'
    * def v = call createOrder { id: '#(order3Id)' }

    # 10. Create Third Order Line With Create Inventory None And Second Holding ID
    * print '10. Create Third Order Line With Create Inventory None And Second Holding ID'
    * def order3Locations = [{ holdingId: '#(holdingId2)', quantityPhysical: 4, quantity: 4 }]
    * call createOrderLine { id: '#(poLine3Id)', orderId: '#(order3Id)', fundId: '#(fundId)', locations: '#(order3Locations)', quantity: 4, createInventory: 'None' }

    # 11. Open First Order
    * print '11. Open First Order'
    * def v = call openOrder { orderId: '#(order1Id)' }

    # 12. Open Second Order
    * print '12. Open Second Order'
    * def v = call openOrder { orderId: '#(order2Id)' }

    # 13. Open Third Order
    * print '13. Open Third Order'
    * def v = call openOrder { orderId: '#(order3Id)' }

    # 14. Prepare Holding Detail Request With Both Holding IDs
    * print '14. Prepare Holding Detail Request With Both Holding IDs'
    * def holdingDetailRequest = { holdingIds: ['#(holdingId)', '#(holdingId2)'] }

    # 15. Call Holding Detail Endpoint
    * print '15. Call Holding Detail Endpoint'
    Given path 'orders/holding-detail'
    And request holdingDetailRequest
    When method POST
    Then status 200

    # 16. Verify Response Structure
    * print '16. Verify Response Structure'
    And match response == '#object'
    * def holdingKey = holdingId + ''
    * def holdingKey2 = holdingId2 + ''
    * def holdingData = karate.get('response["' + holdingKey + '"]')
    * def holdingData2 = karate.get('response["' + holdingKey2 + '"]')
    And match holdingData != null
    And match holdingData2 != null

    # 17. Verify Both Holdings Using Table And Verification Function
    * print '17. Verify Both Holdings Using Table And Verification Function'
    * def expectedPoLineIds1 = [poLine1Id, poLine2Id]
    * def expectedPoLineIds2 = [poLine3Id]
    * def holdingsTable =
    """
    [
      { holdingData: '#(holdingData)', expectedPoLineIds: '#(expectedPoLineIds1)', expectedPiecesCount: 0, expectedItemsCount: 0, holdingName: 'Holding With 2 PoLines' },
      { holdingData: '#(holdingData2)', expectedPoLineIds: '#(expectedPoLineIds2)', expectedPiecesCount: 0, expectedItemsCount: 0, holdingName: 'Holding With 1 PoLine' }
    ]
    """
    * def verifyHoldingWithInventoryNone =
    """
    function(holding) {
      var data = holding.holdingData;
      var expectedPoLineIds = holding.expectedPoLineIds;
      var expectedPiecesCount = holding.expectedPiecesCount;
      var expectedItemsCount = holding.expectedItemsCount;
      var name = holding.holdingName;

      karate.log('Verifying ' + name);

      // Verify collections exist
      karate.match(data.poLines_detail_collection, '!= null');
      karate.match(data.pieces_detail_collection, '!= null');
      karate.match(data.items_detail_collection, '!= null');
      karate.match(data.poLines_detail_collection.poLines_detail, '#array');
      karate.match(data.pieces_detail_collection.pieces_detail, '#array');
      karate.match(data.items_detail_collection.items_detail, '#array');

      // Verify poLines
      var poLines = data.poLines_detail_collection.poLines_detail;
      karate.match(poLines.length, expectedPoLineIds.length);
      karate.match(data.poLines_detail_collection.totalRecords, expectedPoLineIds.length);

      // Verify each poLine has valid id and matches expected ids
      for (var i = 0; i < poLines.length; i++) {
        karate.match(poLines[i].id, '#string');
      }
      var actualPoLineIds = karate.map(poLines, function(poLine){ return poLine.id });
      for (var i = 0; i < expectedPoLineIds.length; i++) {
        karate.match(actualPoLineIds, '#[] ' + expectedPoLineIds[i]);
      }

      // Verify pieces (should be empty for Create Inventory None)
      var pieces = data.pieces_detail_collection.pieces_detail;
      karate.match(pieces.length, expectedPiecesCount);

      // Verify items (should be empty for Create Inventory None)
      var items = data.items_detail_collection.items_detail;
      karate.match(items.length, expectedItemsCount);

      return true;
    }
    """
    * karate.forEach(holdingsTable, verifyHoldingWithInventoryNone)

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

  @Negative
  Scenario: Retrieve Holding Details For Holdings Without PoLines Returns Empty Collections
    * def instanceId = call uuid
    * def holdingId1 = call uuid
    * def holdingId2 = call uuid

    # 1. Create Instance
    * print '1. Create Instance'
    * configure headers = headersAdmin
    * def v = call createInstance { id: '#(instanceId)', title: 'Instance Without PoLines', instanceTypeId: '#(globalInstanceTypeId)' }

    # 2. Create First Holding
    * print '2. Create First Holding'
    * def v = call createHolding { id: '#(holdingId1)', instanceId: '#(instanceId)', locationId: '#(globalLocationsId)', sourceId: '#(globalHoldingsSourceId)' }

    # 3. Create Second Holding
    * print '3. Create Second Holding'
    * def v = call createHolding { id: '#(holdingId2)', instanceId: '#(instanceId)', locationId: '#(globalLocationsId2)', sourceId: '#(globalHoldingsSourceId)' }

    # 4. Prepare Holding Detail Request With Holdings That Have No PoLines
    * print '4. Prepare Holding Detail Request With Holdings That Have No PoLines'
    * def holdingDetailRequest = { holdingIds: ['#(holdingId1)', '#(holdingId2)'] }

    # 5. Call Holding Detail Endpoint
    * print '5. Call Holding Detail Endpoint'
    * configure headers = headersUser
    Given path 'orders/holding-detail'
    And request holdingDetailRequest
    When method POST
    Then status 200

    # 6. Verify Response Contains Holdings With Empty Collections Since Holdings Have No Associated PoLines
    * print '6. Verify Response Contains Holdings With Empty Collections Since Holdings Have No Associated PoLines'
    * def holding1Key = holdingId1 + ''
    * def holding2Key = holdingId2 + ''
    * def holding1Data = karate.get('response["' + holding1Key + '"]')
    * def holding2Data = karate.get('response["' + holding2Key + '"]')
    And match holding1Data.poLines_detail_collection.poLines_detail == []
    And match holding1Data.poLines_detail_collection.totalRecords == 0
    And match holding1Data.pieces_detail_collection.pieces_detail == []
    And match holding1Data.pieces_detail_collection.totalRecords == 0
    And match holding1Data.items_detail_collection.items_detail == []
    And match holding1Data.items_detail_collection.totalRecords == 0
    And match holding2Data.poLines_detail_collection.poLines_detail == []
    And match holding2Data.poLines_detail_collection.totalRecords == 0
    And match holding2Data.pieces_detail_collection.pieces_detail == []
    And match holding2Data.pieces_detail_collection.totalRecords == 0
    And match holding2Data.items_detail_collection.items_detail == []
    And match holding2Data.items_detail_collection.totalRecords == 0


