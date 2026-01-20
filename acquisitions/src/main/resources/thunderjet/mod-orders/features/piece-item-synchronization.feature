# For MODORDERS-494
Feature: Piece and Item synchronization

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
    * def orderId = call uuid
    * def poLineId = call uuid
    * def fundId = globalFundId
    * def receivePieceWithHolding = read('classpath:thunderjet/mod-orders/reusable/receive-piece-with-holding.feature')

  @Positive
  Scenario: Verify piece and item field synchronization for received piece
    * def originalLocationId = globalLocationsId
    * def pieceId = call uuid
    * def testBarcode1 = 'BARCODE-SYNC-' + pieceId
    * def testCallNumber1 = 'CALL-NUM-SYNC-001'
    * def testAccessionNumber1 = 'ACCESSION-001'
    * def testBarcode2 = 'BARCODE-SYNC-UPDATED'
    * def testCallNumber2 = 'CALL-NUM-SYNC-002'
    * def testAccessionNumber2 = 'ACCESSION-002'

    # 1. Create and open order with order line
    * def v = call createOrder { 'id': '#(orderId)' }
    * def v = call createOrderLine { 'id': '#(poLineId)', 'orderId': '#(orderId)', 'createInventory': 'Instance, Holding, Item', 'checkinItems': false }
    * def v = call openOrder { 'orderId': '#(orderId)' }

    # 2. Get title ID and instance ID from order line
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleId = $.titles[0].id

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def instanceId = $.instanceId

    # 3. Get holdings and piece created
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    * def holdingId = $.holdingsRecords[0].id

    * configure headers = headersUser
    Given path 'orders/pieces'
    And param query = 'titleId==' + titleId + ' AND receivingStatus==Expected'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def pieceId = $.pieces[0].id

    # 4. Receive piece
    * table receivePieceDetails
      | pieceId | poLineId | holdingId |
      | pieceId | poLineId | holdingId |
    * def v = call receivePieceWithHolding receivePieceDetails

    # 5. Verify piece is received and get item ID
    Given path 'orders/pieces', pieceId
    And retry until response.receivingStatus == 'Received'
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'
    And match $.itemId == '#present'
    * def itemId = $.itemId

    # 6. Update piece fields (barcode, callNumber, accessionNumber)
    * def updatedPiece = $
    * set updatedPiece.barcode = testBarcode1
    * set updatedPiece.callNumber = testCallNumber1
    * set updatedPiece.accessionNumber = testAccessionNumber1
    Given path 'orders/pieces', pieceId
    And request updatedPiece
    When method PUT
    Then status 204

    # 7. Verify piece fields are updated
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match $.barcode == testBarcode1
    And match $.callNumber == testCallNumber1
    And match $.accessionNumber == testAccessionNumber1

    # 8. Verify item fields are also synchronized
    * configure headers = headersAdmin
    Given path 'inventory/items', itemId
    When method GET
    Then status 200
    And match $.barcode == testBarcode1
    And match $.itemLevelCallNumber == testCallNumber1
    And match $.accessionNumber == testAccessionNumber1

    # 9. Update item fields (barcode, callNumber, accessionNumber)
    * def updatedItem = $
    * set updatedItem.barcode = testBarcode2
    * set updatedItem.itemLevelCallNumber = testCallNumber2
    * set updatedItem.accessionNumber = testAccessionNumber2
    Given path 'inventory/items', itemId
    And request updatedItem
    When method PUT
    Then status 204

    # 10. Verify item fields are updated
    Given path 'inventory/items', itemId
    When method GET
    Then status 200
    And match $.barcode == testBarcode2
    And match $.itemLevelCallNumber == testCallNumber2
    And match $.accessionNumber == testAccessionNumber2

    # 11. Verify piece fields are also synchronized back
    * configure headers = headersUser
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match $.barcode == testBarcode2
    And match $.callNumber == testCallNumber2
    And match $.accessionNumber == testAccessionNumber2


  @Positive
  Scenario: Verify piece and item field synchronization with bound item
    * def orderId2 = call uuid
    * def poLineId2 = call uuid
    * def pieceId = call uuid
    * def boundItemId = call uuid
    * def testBarcode = 'BARCODE-BIND-' + pieceId
    * def testCallNumber = 'CALL-NUM-BIND-001'
    * def testAccessionNumber = 'ACCESSION-BIND-001'
    * def boundBarcode = 'BARCODE-BOUND-' + boundItemId
    * def boundCallNumber = 'CALL-NUM-BOUND-001'
    * def boundAccessionNumber = 'ACCESSION-BOUND-001'
    * def boundBarcode2 = 'BARCODE-BOUND-UPDATED'
    * def boundCallNumber2 = 'CALL-NUM-BOUND-002'
    * def boundAccessionNumber2 = 'ACCESSION-BOUND-002'
    * def testBarcode2 = 'BARCODE-BIND-UPDATED'
    * def testCallNumber2 = 'CALL-NUM-BIND-002'
    * def testAccessionNumber2 = 'ACCESSION-BIND-002'

    # 1. Create and open order with order line
    * def v = call createOrder { 'id': '#(orderId2)' }
    * def v = call createOrderLine { 'id': '#(poLineId2)', 'orderId': '#(orderId2)', 'createInventory': 'Instance, Holding, Item', 'checkinItems': true }

    # Set binderyActive to true on the order line
    Given path 'orders/order-lines', poLineId2
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.details.isBinderyActive = true
    Given path 'orders/order-lines', poLineId2
    And request poLine
    When method PUT
    Then status 204

    * def v = call openOrder { 'orderId': '#(orderId2)' }

    # 2. Get title ID and instance ID from order line
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId2
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleId = $.titles[0].id

    Given path 'orders/order-lines', poLineId2
    When method GET
    Then status 200
    * def instanceId = $.instanceId

    # 3. Get holdings created
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    * def holdingId = $.holdingsRecords[0].id

    # 4. Manually create piece since checkinItems is true
    * configure headers = headersUser
    * def pieceId = call uuid
    * table piecesData
      | id      | poLineId  | titleId | holdingId | format     | createItem |
      | pieceId | poLineId2 | titleId | holdingId | 'Physical' | true       |
    * def v = call createPieceWithHoldingOrLocation piecesData

    # 5. Receive piece
    * table receivePieceDetails
      | pieceId | poLineId  | holdingId |
      | pieceId | poLineId2 | holdingId |
    * def v = call receivePieceWithHolding receivePieceDetails

    # 6. Verify piece is received and get original item ID
    Given path 'orders/pieces', pieceId
    And retry until response.receivingStatus == 'Received'
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'
    And match $.itemId == '#present'
    * def originalItemId = $.itemId

    # 7. Bind piece - this will create a new bound item
    * configure headers = headersUser
    * def bindPieceCollection = read('classpath:samples/mod-orders/bindPieces/bindPieceCollection.json')
    * set bindPieceCollection.poLineId = poLineId2
    * set bindPieceCollection.bindItem.holdingId = holdingId
    * set bindPieceCollection.bindItem.barcode = boundBarcode
    * set bindPieceCollection.bindItem.callNumber = boundCallNumber
    * set bindPieceCollection.bindPieceIds = [ "#(pieceId)" ]
    Given path 'orders/bind-pieces'
    And request bindPieceCollection
    When method POST
    Then status 200
    And match response.itemId == '#present'
    * def newBoundItemId = response.itemId

    # 8. Verify piece is bound to new item
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match $.isBound == true
    And match $.bindItemId == newBoundItemId
    And match $.itemId == originalItemId

    # 9. Update bound item fields (barcode, callNumber, accessionNumber)
    * configure headers = headersAdmin
    Given path 'inventory/items', newBoundItemId
    When method GET
    Then status 200
    * def boundItem = $
    * set boundItem.barcode = boundBarcode2
    * set boundItem.itemLevelCallNumber = boundCallNumber2
    * set boundItem.accessionNumber = boundAccessionNumber2
    Given path 'inventory/items', newBoundItemId
    And request boundItem
    When method PUT
    Then status 204

    # 10. Verify bound item fields are updated
    Given path 'inventory/items', newBoundItemId
    When method GET
    Then status 200
    And match $.barcode == boundBarcode2
    And match $.itemLevelCallNumber == boundCallNumber2
    And match $.accessionNumber == boundAccessionNumber2

    # 11. Verify piece fields are NOT updated (no synchronization with bound item)
    * configure headers = headersUser
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match $.barcode == '#notpresent'
    And match $.callNumber == '#notpresent'
    And match $.accessionNumber == '#notpresent'

    # 12. Update original item fields (barcode, callNumber, accessionNumber)
    * configure headers = headersAdmin
    Given path 'inventory/items', originalItemId
    When method GET
    Then status 200
    * def originalItem = $
    * set originalItem.barcode = testBarcode2
    * set originalItem.itemLevelCallNumber = testCallNumber2
    * set originalItem.accessionNumber = testAccessionNumber2
    Given path 'inventory/items', originalItemId
    And request originalItem
    When method PUT
    Then status 204

    # 13. Verify original item fields are updated
    Given path 'inventory/items', originalItemId
    When method GET
    Then status 200
    And match $.barcode == testBarcode2
    And match $.itemLevelCallNumber == testCallNumber2
    And match $.accessionNumber == testAccessionNumber2

    # 14. Verify piece fields ARE synchronized with original item
    * configure headers = headersUser
    Given path 'orders/pieces', pieceId
    When method GET
    Then status 200
    And match $.barcode == testBarcode2
    And match $.callNumber == testCallNumber2
    And match $.accessionNumber == testAccessionNumber2


  @Positive
  Scenario: Verify piece and item field synchronization for with empty fields
    * def originalLocationId = globalLocationsId
    * def pieceId = call uuid
    * def testBarcode = 'BARCODE-EMPTY-' + pieceId
    * def testCallNumber = 'CALL-NUM-EMPTY-001'
    * def testAccessionNumber = 'ACCESSION-EMPTY-001'

    # 1. Create and open order with order line
    * def v = call createOrder { 'id': '#(orderId)' }
    * def v = call createOrderLine { 'id': '#(poLineId)', 'orderId': '#(orderId)', 'createInventory': 'Instance, Holding, Item', 'checkinItems': false }
    * def v = call openOrder { 'orderId': '#(orderId)' }

    # 2. Get title ID and instance ID from order line
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def titleId = $.titles[0].id

    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def instanceId = $.instanceId

    # 3. Get holdings and piece created
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    And retry until response.totalRecords == 1
    When method GET
    Then status 200
    * def holdingId = $.holdingsRecords[0].id

    * configure headers = headersUser
    Given path 'orders/pieces'
    And param query = 'titleId==' + titleId + ' AND receivingStatus==Expected'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def pieceId = $.pieces[0].id

    # 4. Receive piece
    * table receivePieceDetails
      | pieceId | poLineId | holdingId |
      | pieceId | poLineId | holdingId |
    * def v = call receivePieceWithHolding receivePieceDetails

    # 5. Verify piece is received and get item ID
    Given path 'orders/pieces', pieceId
    And retry until response.receivingStatus == 'Received'
    When method GET
    Then status 200
    And match $.receivingStatus == 'Received'
    And match $.itemId == '#present'
    * def itemId = $.itemId
    * def updatedPiece = $

    # 6. Update piece fields with empty values (barcode, callNumber, accessionNumber)
    * set updatedPiece.barcode = ""
    * set updatedPiece.callNumber = ""
    * set updatedPiece.accessionNumber = ""
    Given path 'orders/pieces', pieceId
    And request updatedPiece
    When method PUT
    Then status 204

    # 7. Verify item fields are synchronized
    * configure headers = headersAdmin
    * def validateItemFields =
    """
    function(response) {
      return (!response.barcode || response.barcode == "") &&
             (!response.itemLevelCallNumber || response.itemLevelCallNumber == "") &&
             (!response.accessionNumber || response.accessionNumber == "")
    }
    """
    Given path 'inventory/items', itemId
    And retry until validateItemFields(response)
    When method GET
    Then status 200
    * def updatedItem = $

    # 8. Update piece fields with non-empty values (barcode, callNumber, accessionNumber)
    * configure headers = headersUser
    * set updatedPiece.barcode = testBarcode
    * set updatedPiece.callNumber = testCallNumber
    * set updatedPiece.accessionNumber = testAccessionNumber
    Given path 'orders/pieces', pieceId
    And request updatedPiece
    When method PUT
    Then status 204

    # 9. Verify item fields are synchronized
    * configure headers = headersAdmin
    Given path 'inventory/items', itemId
    When method GET
    Then status 200
    And match $.barcode == testBarcode
    And match $.itemLevelCallNumber == testCallNumber
    And match $.accessionNumber == testAccessionNumber
    * def updatedItem = $

    # 10. Update item fields with empty values (barcode, callNumber, accessionNumber)
    * set updatedItem.barcode = ""
    * set updatedItem.itemLevelCallNumber = ""
    * set updatedItem.accessionNumber = ""
    Given path 'inventory/items', itemId
    And request updatedItem
    When method PUT
    Then status 204

    # 11. Verify piece fields are also synchronized back
    * configure headers = headersUser
    * def validatePieceFields =
    """
    function(response) {
      return (!response.barcode || response.barcode == "") &&
             (!response.callNumber || response.callNumber == "") &&
             (!response.accessionNumber || response.accessionNumber == "")
    }
    """
    Given path 'orders/pieces', pieceId
    And retry until validatePieceFields(response)
    When method GET
    Then status 200