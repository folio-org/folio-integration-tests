@parallel=false
# MODORDERS-538
Feature: Should create and delete pieces for non package mixed POL with quantity POL updates when manual is false

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

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4
    * def poLineTitleId = callonce uuid5
    * def initialHoldingId = globalHoldingId1
    * def initialInstanceId = globalInstanceId1
    * def pieceIdWithoutItemAndHolding = callonce uuid6
    * def pieceIdWithoutItemAndLocation = callonce uuid7
    * def pieceIdWithItemAndHolding = callonce uuid8
    * def pieceIdWithItemAndLocation = callonce uuid9


  Scenario: Create finances
    # this is needed for instance if a previous test does a rollover which changes the global fund
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)' }
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)' }

  Scenario: Create an order
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201


  Scenario: Create an mixed order line with isPackage=false
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-mixed-order-line.json')
    * set poLine.id = poLineId
    * set poLine.cost.quantityElectronic = 2
    * set poLine.purchaseOrderId = orderId
    * set poLine.instanceId = initialInstanceId
    * set poLine.isPackage = false
    * set poLine.fundDistribution[0].fundId = fundId
    * remove poLine.locations[0].locationId
    * set poLine.locations[0].holdingId = initialHoldingId
    * set poLine.locations[0].quantity = 3
    * set poLine.locations[0].quantityElectronic = 2
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201
    * def createdLine = $
    * def poLineNumber = createdLine.createdLine
    And match $.instanceId == initialInstanceId


  Scenario: Open the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

  Scenario: Check inventory and order items after open order
    * print 'Get the instanceId and holdingId from the po line'
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def instanceId = response.instanceId
    * def holdingId = response.locations[0].holdingId

    * print 'Check items'
    * configure headers = headersAdmin
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 1
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItem = physicalItems[0]
    And assert physicalItem != null
    And assert physicalItem.holdingsRecordId == holdingId
    And assert physicalItem.status.name == 'On order'

    * print 'Check if pieces were created when the order was opened'
    * configure headers = headersUser
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 3
    * def physicalPieces = $.pieces[?(@.format == 'Physical')]
    * def physicalPiece = physicalPieces[0]

    * def electronicPieces = $.pieces[?(@.format == 'Electronic')]
    * def electronicPiece = electronicPieces[0]
    And assert physicalPiece.receivingStatus == 'Expected'
    And assert physicalPiece.itemId != null
    And assert physicalPiece.itemId == physicalItem.id
    And assert physicalPiece.holdingId == holdingId
    And assert electronicPiece.receivingStatus == 'Expected'
    And assert electronicPiece.itemId == null
    And assert electronicPiece.holdingId == holdingId

    * print 'Check holdings'
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings', initialHoldingId
    When method GET
    Then status 200
    And assert response.id == initialHoldingId

# -- DELETE Physical piece -- #
  Scenario: Delete Physical piece without holding deletion
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 3
    * def physicalPiecesForDelete = $.pieces[?(@.format == 'Physical')]
    * def physicalPieceForDelete = physicalPiecesForDelete[0]

    * print 'Delete Physical piece without holding deletion'
    Given path 'orders/pieces', physicalPieceForDelete.id
    When method DELETE
    Then status 204

    * print 'Check physical item should be deleted'
    * configure headers = headersAdmin
    Given path 'inventory/items', physicalPieceForDelete.itemId
    When method GET
    Then status 404

    * print 'Check physical piece should be deleted'
    * configure headers = headersUser
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def electronicPiecesAfterDelete = $.pieces[?(@.format == 'Electronic')]
    And assert electronicPiecesAfterDelete[0].receivingStatus == 'Expected'

    * print 'Check holding should not be deleted, because flag "deleteHolding" was not provided and exist item'
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings', initialHoldingId
    When method GET
    Then status 200
    And assert response.id == initialHoldingId

  Scenario: Check order and transaction after Physical piece deletion
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def poLine = $.poLines[0]
    And match $.workflowStatus == 'Open'
    And match $.totalItems == 2
    And match $.totalEstimatedPrice == 6
    And match poLine.cost.quantityElectronic == 2
    And match poLine.cost.quantityPhysical == 0
    And match poLine.locations[0].holdingId == initialHoldingId
    And match poLine.locations[0].quantity == 2
    And match poLine.locations[0].quantityElectronic == 2
    And match poLine.locations[0].quantityPhysical == '#notpresent' || poLine.locations[0].quantityPhysical == 0

    * print 'Check encumbrances initial value'
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    And match $.totalRecords == 1
    * def encumbranceTr = $.transactions[0]
    And match encumbranceTr.amount == 6.0
    And match encumbranceTr.encumbrance.initialAmountEncumbered == 6.0
    And match encumbranceTr.encumbrance.status == 'Unreleased'

 #-- DELETE Electronic piece -- #
  Scenario: Delete Electronic piece without holding deletion
    * print 'Check physical piece should be deleted'
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def electronicPieces = $.pieces[?(@.format == 'Electronic')]
    * def electronicPiece = electronicPieces[0]
    And assert electronicPiece.receivingStatus == 'Expected'

    * print 'Delete Electronic piece without holding deletion'
    Given path 'orders/pieces', electronicPiece.id
    When method DELETE
    Then status 204

    * print 'Check Electronic item should be deleted'
    * configure headers = headersAdmin
    Given path 'inventory/items', electronicPiece.id
    When method GET
    Then status 404

    * print 'Check Electronic piece should be deleted'
    * configure headers = headersUser
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1

    * print 'Check holding should not be deleted, because flag "deleteHolding" was not provided and not existing items'
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings', initialHoldingId
    When method GET
    Then status 200
    And assert response.id == initialHoldingId

  Scenario: Check order and transaction after Electronic piece deletion
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    * def poLine = orderResponse.poLines[0]
    And match poLine.locations == '#[1]'
    And match orderResponse.workflowStatus == 'Open'
    And match orderResponse.totalItems == 1
    And match orderResponse.totalEstimatedPrice == 3.0
    And match poLine.cost.quantityElectronic == 1
    And match poLine.cost.quantityPhysical == 0


    * print 'Check encumbrances initial value'
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    And match $.totalRecords == 1
    * def encumbranceTr = $.transactions[0]
    And assert encumbranceTr.amount == 3.0
    And assert encumbranceTr.encumbrance.initialAmountEncumbered == 3.0
    And assert encumbranceTr.encumbrance.status == 'Unreleased'

  Scenario: Create set of pieces
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    * def title = $.titles[0]
    * def titleId = title.id

    Given path 'orders/pieces'
    And request
    """
    {
      id: "#(pieceIdWithItemAndHolding)",
      format: "Physical",
      holdingId: "#(initialHoldingId)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId)"
    }
    """
    And param createItem = true
    When method POST
    Then status 201

    Given path 'orders/pieces'
    And request
    """
    {
      id: "#(pieceIdWithoutItemAndHolding)",
      format: "Electronic",
      holdingId: "#(initialHoldingId)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId)"
    }
    """
    When method POST
    Then status 201

    Given path 'orders/pieces'
    And request
    """
    {
      id: "#(pieceIdWithItemAndLocation)",
      format: "Physical",
      locationId: "#(globalLocationsId)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId)"
    }
    """
    And param createItem = true
    When method POST
    Then status 201

    Given path 'orders/pieces'
    And request
    """
    {
      id: "#(pieceIdWithoutItemAndLocation)",
      format: "Electronic",
      locationId: "#(globalLocationsId)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId)"
    }
    """
    When method POST
    Then status 201

  Scenario: Check order and transaction after adding set of pieces
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    * def poLine = orderResponse.poLines[0]
    And match orderResponse.workflowStatus == 'Open'
    And match orderResponse.totalItems == 5
    And match orderResponse.totalEstimatedPrice == 17.0
    And match poLine.cost.quantityElectronic == 3
    And match poLine.cost.quantityPhysical == 2
    And match poLine.locations == '#[3]'

    * print 'Check encumbrances initial value'
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    And match $.totalRecords == 1
    * def encumbranceTr = $.transactions[0]
    And assert encumbranceTr.amount == 17.0
    And assert encumbranceTr.encumbrance.initialAmountEncumbered == 17.0
    And assert encumbranceTr.encumbrance.status == 'Unreleased'

   #-- DELETE Electronic piece -- #
  Scenario: Delete Physical piece with item and with holding deletion
    * print 'Delete piece With Item And initially Location in the piece with holding deletion'
    Given path 'orders/pieces', pieceIdWithItemAndLocation
    When method GET
    Then status 200
    * def pieceForDelete = $
    * def pieceItemId = $.itemId
    * def pieceHoldingId = $.holdingId

    * print 'Delete piece With Item And initially Location in the piece with holding deletion'
    Given path 'orders/pieces', pieceIdWithItemAndLocation
    And param deleteHolding = true
    When method DELETE
    Then status 204

    * print 'Check item should be deleted'
    * configure headers = headersAdmin
    Given path 'inventory/items', pieceItemId
    When method GET
    Then status 404

    * print 'Check Electronic piece should be deleted'
    * configure headers = headersUser
    Given path 'orders/pieces', pieceIdWithItemAndLocation
    When method GET
    Then status 404

    * print 'Check holding should be deleted, because flag "deleteHolding" was provided and not existing items'
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings', pieceHoldingId
    When method GET
    Then status 404

  Scenario: Check order and transaction after Physical piece and connected holding and item deletion
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    * def poLine = orderResponse.poLines[0]
    And match orderResponse.workflowStatus == 'Open'
    And match orderResponse.totalItems == 4
    And match orderResponse.totalEstimatedPrice == 13.0
    And match poLine.cost.quantityElectronic == 3
    And match poLine.cost.quantityPhysical == 1
    And match poLine.locations == '#[2]'

    * print 'Check encumbrances initial value'
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    And match $.totalRecords == 1
    * def encumbranceTr = $.transactions[0]
    And match encumbranceTr.amount == 13.0
    And match encumbranceTr.encumbrance.initialAmountEncumbered == 13.0
    And match encumbranceTr.encumbrance.status == 'Unreleased'

   #-- DELETE Electronic piece -- #
  Scenario: Delete Electronic piece without item and with holding deletion, where still connected items
    * print 'Delete Electronic piece without item and with holding deletion, where still connected items'
    Given path 'orders/pieces', pieceIdWithoutItemAndHolding
    When method GET
    Then status 200
    * def pieceForDelete = $
    * def pieceItemId = $.itemId
    * def pieceHoldingId = $.holdingId

    * print 'Delete piece With Item And initially Global holding in the piece with holding deletion'
    Given path 'orders/pieces', pieceIdWithoutItemAndHolding
    And param deleteHolding = true
    When method DELETE
    Then status 204

    * print 'Check Electronic piece should be deleted'
    Given path 'orders/pieces', pieceIdWithoutItemAndHolding
    When method GET
    Then status 404

    * print 'Check holding should not be deleted and flag "deleteHolding" was provided but existing items'
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings', pieceHoldingId
    When method GET
    Then status 200

  Scenario: Check order and transaction after Electronic piece deletion without connected holding deletion
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200
    * def orderResponse = $
    * def poLine = orderResponse.poLines[0]
    And match orderResponse.workflowStatus == 'Open'
    And match orderResponse.totalItems == 3
    And match orderResponse.totalEstimatedPrice == 10.0
    And match poLine.cost.quantityElectronic == 2
    And match poLine.cost.quantityPhysical == 1
    And match poLine.locations == '#[2]'

    * print 'Check encumbrances initial value'
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    And match $.totalRecords == 1
    * def encumbranceTr = $.transactions[0]
    And match encumbranceTr.amount == 10.0
    And match encumbranceTr.encumbrance.initialAmountEncumbered == 10.0
    And match encumbranceTr.encumbrance.status == 'Unreleased'
