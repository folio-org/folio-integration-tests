@parallel=false
# for https://issues.folio.org/browse/MODORDERS-583
Feature: If I don't choose to create an item when creating the piece. If I edit that piece and select create item the item must created

  Background:
    * url baseUrl
    #* callonce dev {tenant: 'test_orders1'}
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure headers = headersUser

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4
    * def poLineTitleId = callonce uuid5
    * def initialHoldingId = globalHoldingId1
    * def holdingToPiece2 = globalHoldingId2
    * def initialInstanceId = globalInstanceId1
    * def pieceIdWithItemAndLocation = callonce uuid6

  Scenario: Create finances
    # this is needed for instance if a previous test does a rollover which changes the global fund
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}


  Scenario: Should update location in the POL if change Location to a different holding on that instance for piece
    * configure headers = headersUser
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


  * print 'Create an physical order line with isPackage=false and 2 items'
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.instanceId = initialInstanceId
    * set poLine.isPackage = false
    * set poLine.fundDistribution[0].fundId = fundId
    * remove poLine.locations[0].locationId
    * set poLine.locations[0].holdingId = initialHoldingId
    * set poLine.locations[0].quantityPhysical = 1
    * set poLine.cost.quantityPhysical = 1
    Given path 'orders/order-lines'
    * configure headers = headersUser
    And request poLine
    When method POST
    Then status 201
    * def createdLine = $
    * def poLineNumber = createdLine.createdLine
    And match $.instanceId == initialInstanceId


  * print 'Open the order with 1 items'
    Given path 'orders/composite-orders', orderId
    * configure headers = headersUser
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204

  * print 'Check inventory and order items after open order'
    * print 'Get the instanceId and holdingId from the po line'
    Given path 'orders/order-lines', poLineId
    * configure headers = headersUser
    When method GET
    Then status 200
    * def poLineInstanceId = response.instanceId
    * def poLineHoldingId = response.locations[0].holdingId

    * print 'Check items'
    Given path 'inventory/items'
    * configure headers = headersAdmin
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 1
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItemAfterOpenOrder1 = physicalItems[0]
    And assert physicalItemAfterOpenOrder1 != null
    And assert physicalItemAfterOpenOrder1.holdingsRecordId == poLineHoldingId
    And assert physicalItemAfterOpenOrder1.status.name == 'On order'


    * print 'Check if pieces were created when the order was opened'
    Given path 'orders/pieces'
    * configure headers = headersUser
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * print 'Physical item 1 : ' + physicalItemAfterOpenOrder1.id
    * def physicalPieceAfterOpenOrder1 = karate.jsonPath(response, '$.pieces[*][?(@.itemId == "' + physicalItemAfterOpenOrder1.id + '")]')[0]
    And assert physicalPieceAfterOpenOrder1.receivingStatus == 'Expected'
    And assert physicalPieceAfterOpenOrder1.holdingId == poLineHoldingId


    * print 'Check holdings'
    Given path 'holdings-storage/holdings', poLineHoldingId
    * configure headers = headersAdmin
    When method GET
    Then status 200
    And assert response.id == poLineHoldingId

    * print 'Retrieve POL titles'
    * configure headers = headersAdmin
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    * def title = $.titles[0]
    * def titleId = title.id

    * print 'Create piece without item creation and provided location'
    Given path 'orders/pieces'
    * configure headers = headersUser
    And request
    """
    {
      id: "#(pieceIdWithItemAndLocation)",
      format: "Physical",
      holdingId: "#(holdingToPiece2)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId)"
    }
    """
    When method POST
    Then status 201
    * def newCreatedPiece = $
    * call pause 900

    * print 'Update piece with item creation and provided location'
    Given path 'orders/pieces', newCreatedPiece.id
    * configure headers = headersUser
    And request newCreatedPiece
    And param createItem = true
    When method PUT
    Then status 204
    * call pause 900

    Given path 'orders/pieces'
    * configure headers = headersUser
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def physicalPieceAfterUpdate1 = karate.jsonPath(response, '$.pieces[*][?(@.holdingId == "' + poLineHoldingId + '")]')[0]
    * def physicalPieceAfterUpdate2 = karate.jsonPath(response, '$.pieces[*][?(@.holdingId == "' + holdingToPiece2 + '")]')[0]
    And assert physicalPieceAfterUpdate1.receivingStatus == 'Expected'
    And assert physicalPieceAfterUpdate2.receivingStatus == 'Expected'

    * print 'Check physical item should be updated'
    Given path 'inventory/items', physicalPieceAfterUpdate2.itemId
    * configure headers = headersAdmin
    When method GET
    Then status 200
    And match $.holdingsRecordId == holdingToPiece2


    * print 'Check holding should not be deleted, because flag "deleteHolding" was not provided and exist item'
    Given path 'holdings-storage/holdings', initialHoldingId
    * configure headers = headersAdmin
    When method GET
    Then status 200
    And assert response.id == initialHoldingId
    * call pause 900

    * print 'Check order and transaction after Physical piece update'
    Given path 'orders/composite-orders', orderId
    * configure headers = headersUser
    When method GET
    * def poLine = $.compositePoLines[0]
    And match $.workflowStatus == 'Open'
    And match $.totalItems == 2
    And match $.totalEstimatedPrice == 2.0
    And match poLine.cost.quantityElectronic == '#notpresent'
    And match poLine.cost.quantityPhysical == 2
    * def physicalLocationAfterUpdate1 = karate.jsonPath(response.compositePoLines[0], '$.locations[*][?(@.holdingId == "' + poLineHoldingId + '")]')[0]
    And match physicalLocationAfterUpdate1.quantity == 1
    And match physicalLocationAfterUpdate1.quantityPhysical == 1
    And match physicalLocationAfterUpdate1.quantityElectronic == '#notpresent'
    * def physicalLocationAfterUpdate2 = karate.jsonPath(response.compositePoLines[0], '$.locations[*][?(@.holdingId == "' + holdingToPiece2 + '")]')[0]
    And match physicalLocationAfterUpdate2.quantity == 1
    And match physicalLocationAfterUpdate2.quantityPhysical == 1
    And match physicalLocationAfterUpdate2.quantityElectronic == '#notpresent'


    * print 'Check encumbrances initial value'
    Given path 'finance/transactions'
    * configure headers = headersAdmin
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    And match $.totalRecords == 1
    * def encumbranceTr = $.transactions[0]
    And assert encumbranceTr.amount == 2.0
    And assert encumbranceTr.encumbrance.initialAmountEncumbered == 2.0
    And assert encumbranceTr.encumbrance.status == 'Unreleased'