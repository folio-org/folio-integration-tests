@parallel=false
# for https://issues.folio.org/browse/MODORDERS-580
Feature: Should update location in the POL if change Location to a different holding on that instance for piece

  Background:
    * url baseUrl
    #* callonce dev {tenant: 'testorders1'}
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
    * set poLine.locations[0].quantityPhysical = 2
    * set poLine.cost.quantityPhysical = 2
    Given path 'orders/order-lines'
    * configure headers = headersUser
    And request poLine
    When method POST
    Then status 201
    * def createdLine = $
    * def poLineNumber = createdLine.createdLine
    And match $.instanceId == initialInstanceId


  * print 'Open the order with 2 items'
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
    And match $.totalRecords == 2
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItemAfterOpenOrder1 = physicalItems[0]
    And assert physicalItemAfterOpenOrder1 != null
    And assert physicalItemAfterOpenOrder1.holdingsRecordId == poLineHoldingId
    And assert physicalItemAfterOpenOrder1.status.name == 'On order'
    * def physicalItemAfterOpenOrder2 = physicalItems[1]
    And assert physicalItemAfterOpenOrder2 != null
    And assert physicalItemAfterOpenOrder2.holdingsRecordId == poLineHoldingId
    And assert physicalItemAfterOpenOrder2.status.name == 'On order'

    * print 'Check if pieces were created when the order was opened'
    Given path 'orders/pieces'
    * configure headers = headersUser
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * print 'Physical item 1 : ' + physicalItemAfterOpenOrder1.id
    * def physicalPieceAfterOpenOrder1 = karate.jsonPath(response, '$.pieces[*][?(@.itemId == "' + physicalItemAfterOpenOrder1.id + '")]')[0]
    * def physicalPieceAfterOpenOrder2 = karate.jsonPath(response, '$.pieces[*][?(@.itemId == "' + physicalItemAfterOpenOrder2.id + '")]')[0]
    * print 'Physical item 2 : ' + physicalItemAfterOpenOrder2.id
    And assert physicalPieceAfterOpenOrder1.receivingStatus == 'Expected'
    And assert physicalPieceAfterOpenOrder1.holdingId == poLineHoldingId
    And assert physicalPieceAfterOpenOrder2.receivingStatus == 'Expected'
    And assert physicalPieceAfterOpenOrder2.holdingId == poLineHoldingId

    * print 'Check holdings'
    Given path 'holdings-storage/holdings', poLineHoldingId
    * configure headers = headersAdmin
    When method GET
    Then status 200
    And assert response.id == poLineHoldingId


    * print 'Update Physical piece without holding deletion and update location with another holding from same instance'
    Given path 'orders/pieces', physicalPieceAfterOpenOrder2.id
    * set physicalPieceAfterOpenOrder2.holdingId = holdingToPiece2
    * configure headers = headersUser
    And  request physicalPieceAfterOpenOrder2
    When method PUT
    Then status 204

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