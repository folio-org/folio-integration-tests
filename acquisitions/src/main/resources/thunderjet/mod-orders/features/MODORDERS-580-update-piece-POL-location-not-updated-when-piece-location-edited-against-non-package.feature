# For MODORDERS-580
Feature: Should update location in the POL if change Location to a different holding on that instance for piece

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


  Scenario: Should update location in the POL if change Location to a different holding on that instance for piece
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid
    * def poLineTitleId = call uuid
    * def initialHoldingId = globalHoldingId1
    * def holdingToPiece2 = globalHoldingId2
    * def initialInstanceId = globalInstanceId1

    # 1. Create finances
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 10000, fundId: '#(fundId)' }

    # 2. Create order
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create a physical order line with isPackage=false and 2 items
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
    And request poLine
    When method POST
    Then status 201
    * def createdLine = $
    * def poLineNumber = createdLine.createdLine
    And match $.instanceId == initialInstanceId

    # 4. Open the order with 2 items
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Get the instanceId and holdingId from the po line
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLineInstanceId = response.instanceId
    * def poLineHoldingId = response.locations[0].holdingId

    # 6. Check items
    * configure headers = headersAdmin
    Given path 'inventory/items'
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

    # 7. Check if pieces were created when the order was opened
    * configure headers = headersUser
    Given path 'orders/pieces'
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

    # 8. Check holdings
    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings', poLineHoldingId
    When method GET
    Then status 200
    And assert response.id == poLineHoldingId

    # 9. Update Physical piece without holding deletion and update location with another holding from same instance
    * configure headers = headersUser
    Given path 'orders/pieces', physicalPieceAfterOpenOrder2.id
    * set physicalPieceAfterOpenOrder2.holdingId = holdingToPiece2
    And  request physicalPieceAfterOpenOrder2
    When method PUT
    Then status 204

    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def physicalPieceAfterUpdate1 = karate.jsonPath(response, '$.pieces[*][?(@.holdingId == "' + poLineHoldingId + '")]')[0]
    * def physicalPieceAfterUpdate2 = karate.jsonPath(response, '$.pieces[*][?(@.holdingId == "' + holdingToPiece2 + '")]')[0]
    And assert physicalPieceAfterUpdate1.receivingStatus == 'Expected'
    And assert physicalPieceAfterUpdate2.receivingStatus == 'Expected'

    # 10. Check physical item should be updated
    * configure headers = headersAdmin
    Given path 'inventory/items', physicalPieceAfterUpdate2.itemId
    When method GET
    Then status 200
    And match $.holdingsRecordId == holdingToPiece2

    # 11. Check holding should not be deleted, because flag "deleteHolding" was not provided and exist item
    Given path 'holdings-storage/holdings', initialHoldingId
    When method GET
    Then status 200
    And assert response.id == initialHoldingId

    # 12. Check order and transaction after Physical piece update
    * configure headers = headersUser
    Given path 'orders/composite-orders', orderId
    When method GET
    * def poLine = $.poLines[0]
    And match $.workflowStatus == 'Open'
    And match $.totalItems == 2
    And match $.totalEstimatedPrice == 2.0
    And match poLine.cost.quantityElectronic == '#notpresent'
    And match poLine.cost.quantityPhysical == 2
    * def physicalLocationAfterUpdate1 = karate.jsonPath(response.poLines[0], '$.locations[*][?(@.holdingId == "' + poLineHoldingId + '")]')[0]
    And match physicalLocationAfterUpdate1.quantity == 1
    And match physicalLocationAfterUpdate1.quantityPhysical == 1
    And match physicalLocationAfterUpdate1.quantityElectronic == '#notpresent'
    * def physicalLocationAfterUpdate2 = karate.jsonPath(response.poLines[0], '$.locations[*][?(@.holdingId == "' + holdingToPiece2 + '")]')[0]
    And match physicalLocationAfterUpdate2.quantity == 1
    And match physicalLocationAfterUpdate2.quantityPhysical == 1
    And match physicalLocationAfterUpdate2.quantityElectronic == '#notpresent'

    # 13. Check encumbrances initial value
    * configure headers = headersAdmin
    Given path 'finance/transactions'
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    And match $.totalRecords == 1
    * def encumbranceTr = $.transactions[0]
    And assert encumbranceTr.amount == 2.0
    And assert encumbranceTr.encumbrance.initialAmountEncumbered == 2.0
    And assert encumbranceTr.encumbrance.status == 'Unreleased'
