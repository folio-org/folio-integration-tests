@parallel=false
# for https://issues.folio.org/browse/MODORDERS-579
Feature: Should create and update pieces for non package mixed POL with quantity POL updates when manual is false

  Background:
    * url baseUrl
    #* callonce dev {tenant: 'test_orders6'}
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
    * def initialInstanceId = globalInstanceId1
    * def pieceIdWithoutItemAndHolding = callonce uuid6
    * def pieceIdWithoutItemAndLocation = callonce uuid7
    * def pieceIdWithItemAndHolding = callonce uuid8
    * def pieceIdWithItemAndLocation = callonce uuid9
    * def codePrefix = callonce random_string
    * def newLocationForPhysicalPiece =  callonce uuid10
    * def newElectronicCreatedHoldingIdFirstUpdate = callonce uuid11
    * def newElectronicCreatedHoldingIdSecondUpdate = callonce uuid12

  Scenario: Create finances
    # this is needed for instance if a previous test does a rollover which changes the global fund
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}

  Scenario Outline: create locations
    # create locations
    * def locationId = <locationId>
    * def code = <code>
    * def name = <name>
    Given path 'locations'
    * configure headers = headersAdmin
    And request
    """
    {
        "id": "#(locationId)",
        "name": "#(codePrefix +name)",
        "code": "#(codePrefix +code)",
        "isActive": true,
        "institutionId": "40ee00ca-a518-4b49-be01-0638d0a4ac57",
        "campusId": "62cf76b7-cca5-4d33-9217-edf42ce1a848",
        "libraryId": "5d78803e-ca04-4b4a-aeae-2c63b924518b",
        "primaryServicePoint": "3a40852d-49fd-4df2-a1f9-6e2641a6e91f",
        "servicePointIds": [
            "3a40852d-49fd-4df2-a1f9-6e2641a6e91f"
        ]
    }
    """
    When method POST
    Then status 201

    Examples:
      | locationId                     | code                | name       |
      | newLocationForPhysicalPiece    | 'PhysLocationCode' |'PhysLocation'|
      | newElectronicCreatedHoldingIdFirstUpdate  | 'ElecLocationCode' |'ElecLocation'|
      | newElectronicCreatedHoldingIdSecondUpdate | 'ElecLocationCode2' |'ElecLocation2'|

  Scenario: Create an order
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


  Scenario: Create an mixed order line with isPackage=false
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-mixed-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.instanceId = initialInstanceId
    * set poLine.isPackage = false
    * set poLine.fundDistribution[0].fundId = fundId
    * remove poLine.locations[0].locationId
    * set poLine.locations[0].holdingId = initialHoldingId
    Given path 'orders/order-lines'
    * configure headers = headersUser
    And request poLine
    When method POST
    Then status 201
    * def createdLine = $
    * def poLineNumber = createdLine.createdLine
    And match $.instanceId == initialInstanceId


  Scenario: Open the order
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

  Scenario: Check inventory and order items after open order
    * print 'Get the instanceId and holdingId from the po line'
    Given path 'orders/order-lines', poLineId
    * configure headers = headersUser
    When method GET
    Then status 200
    * def instanceId = response.instanceId
    * def holdingId = response.locations[0].holdingId

    * print 'Check items'
    Given path 'inventory/items'
    * configure headers = headersAdmin
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 1
    * def physicalItems = $.items[?(@.materialType.name == 'Phys')]
    * def physicalItem = physicalItems[0]
    And assert physicalItem != null
    And assert physicalItem.holdingsRecordId == holdingId
    And assert physicalItem.status.name == 'On order'

    * print 'Check if pieces were created when the order was opened'
    Given path 'orders/pieces'
    * configure headers = headersUser
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
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
    Given path 'holdings-storage/holdings', initialHoldingId
    * configure headers = headersAdmin
    When method GET
    Then status 200
    And assert response.id == initialHoldingId

 #-- Update Physical piece -- #
  Scenario: Update Physical piece without holding deletion and in the piece there is location reference
    Given path 'orders/pieces'
    * configure headers = headersUser
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def physicalPiecesForUpdate = $.pieces[?(@.format == 'Physical')]
    * def physicalPieceForUpdate = physicalPiecesForUpdate[0]
    * set physicalPieceForUpdate.locationId = newLocationForPhysicalPiece
    * remove physicalPieceForUpdate.holdingId

    * print 'Update Physical piece without holding deletion'
    Given path 'orders/pieces', physicalPieceForUpdate.id
    * configure headers = headersUser
    And  request physicalPieceForUpdate
    When method PUT
    Then status 204

    Given path 'orders/pieces'
    * configure headers = headersUser
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def electronicPieceAfterUpdate = $.pieces[?(@.format == 'Electronic')]
    And assert electronicPieceAfterUpdate[0].receivingStatus == 'Expected'
    * def physicalPiecesAfterUpdate = $.pieces[?(@.format == 'Physical')]
    * def physicalPieceAfterUpdate = physicalPiecesAfterUpdate[0]
    And match physicalPieceAfterUpdate.locationId == '#notpresent'
    And assert physicalPieceAfterUpdate.receivingStatus == 'Expected'
    * def newCreatedHoldingId = physicalPieceAfterUpdate.holdingId

    * print 'Check physical item should be updated'
    Given path 'inventory/items', physicalPieceAfterUpdate.itemId
    * configure headers = headersAdmin
    When method GET
    Then status 200
    And match $.holdingsRecordId == newCreatedHoldingId


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
    Then status 200
    * def poLine = $.compositePoLines[0]
    And match $.workflowStatus == 'Open'
    And match $.totalItems == 2
    And match $.totalEstimatedPrice == 7.0
    And match poLine.cost.quantityElectronic == 1
    And match poLine.cost.quantityPhysical == 1
    * def physicalLocationsAfterUpdate = $.compositePoLines[0].locations[?(@.quantityPhysical == 1)]
    * def physicalLocationAfterUpdate = physicalLocationsAfterUpdate[0]
    And match physicalLocationAfterUpdate.holdingId == newCreatedHoldingId
    And match physicalLocationAfterUpdate.quantity == 1
    And match physicalLocationAfterUpdate.quantityPhysical == 1
    * def electronicalLocationsAfterUpdate = $.compositePoLines[0].locations[?(@.quantityElectronic == 1)]
    * def electronicalLocationAfterUpdate = electronicalLocationsAfterUpdate[0]
    And match electronicalLocationAfterUpdate.holdingId == initialHoldingId
    And match electronicalLocationAfterUpdate.quantity == 1
    And match electronicalLocationAfterUpdate.quantityElectronic == 1


    * print 'Check encumbrances initial value'
    Given path 'finance/transactions'
    * configure headers = headersAdmin
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    And match $.totalRecords == 1
    * def encumbranceTr = $.transactions[0]
    And assert encumbranceTr.amount == 7.0
    And assert encumbranceTr.encumbrance.initialAmountEncumbered == 7.0
    And assert encumbranceTr.encumbrance.status == 'Unreleased'

# -- Update Physical piece -- #
 * print 'Update Physical piece without holding deletion and in the piece there is initial holding reference'
    Given path 'orders/pieces'
    * configure headers = headersUser
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def physicalPiecesForUpdate = $.pieces[?(@.format == 'Physical')]
    * def physicalPieceForUpdate = physicalPiecesForUpdate[0]
    * set physicalPieceForUpdate.holdingId = initialHoldingId

    * print 'Update Physical piece without holding deletion'
    Given path 'orders/pieces', physicalPieceForUpdate.id
    * configure headers = headersUser
    And  request physicalPieceForUpdate
    When method PUT
    Then status 204

    Given path 'orders/pieces'
    * configure headers = headersUser
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def electronicPieceAfterUpdate = $.pieces[?(@.format == 'Electronic')]
    And assert electronicPieceAfterUpdate[0].receivingStatus == 'Expected'
    * def physicalPiecesAfterUpdate = $.pieces[?(@.format == 'Physical')]
    * def physicalPieceAfterUpdate = physicalPiecesAfterUpdate[0]
    And match physicalPieceAfterUpdate.locationId == '#notpresent'
    And assert physicalPieceAfterUpdate.receivingStatus == 'Expected'
    And assert physicalPieceAfterUpdate.holdingId == initialHoldingId

    * print 'Check physical item should be updated'
    Given path 'inventory/items', physicalPieceAfterUpdate.itemId
    * configure headers = headersAdmin
    When method GET
    Then status 200
    And match $.holdingsRecordId == initialHoldingId


    * print 'Check holding should not be deleted, because flag "deleteHolding" was not provided and exist item'
    Given path 'holdings-storage/holdings', newCreatedHoldingId
    * configure headers = headersAdmin
    When method GET
    Then status 200
    And assert response.id == newCreatedHoldingId

    * print 'Check order and transaction after Physical piece update'
    Given path 'orders/composite-orders', orderId
    * configure headers = headersUser
    When method GET
    Then status 200
    * def poLine = $.compositePoLines[0]
    And match $.workflowStatus == 'Open'
    And match $.totalItems == 2
    And match $.totalEstimatedPrice == 7.0
    And match poLine.cost.quantityElectronic == 1
    And match poLine.cost.quantityPhysical == 1
    And match response.compositePoLines[0].locations == '#[1]'
    And match poLine.locations[0].holdingId == initialHoldingId
    And match poLine.locations[0].quantity ==2
    And match poLine.locations[0].quantityElectronic == 1
    And match poLine.locations[0].quantityPhysical == 1

    * print 'Check encumbrances initial value'
    Given path 'finance/transactions'
    * configure headers = headersAdmin
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    And match $.totalRecords == 1
    * def encumbranceTr = $.transactions[0]
    And assert encumbranceTr.amount == 7.0
    And assert encumbranceTr.encumbrance.initialAmountEncumbered == 7.0
    And assert encumbranceTr.encumbrance.status == 'Unreleased'

# -- Update Electronic piece -- #
    * print 'Update Electronic piece without holding deletion and create item true should fail, because inventory option is Instance, Holding'
    Given path 'orders/pieces'
    * configure headers = headersUser
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def electronicPiecesForUpdate = $.pieces[?(@.format == 'Electronic')]
    * def electronicPieceForUpdate = electronicPiecesForUpdate[0]
    * remove electronicPieceForUpdate.holdingId
    * set electronicPieceForUpdate.locationId = newElectronicCreatedHoldingIdFirstUpdate

    * print 'Update Physical piece without holding deletion'
    Given path 'orders/pieces', electronicPieceForUpdate.id
    * configure headers = headersUser
    And  request electronicPieceForUpdate
    And param createItem = true
    When method PUT
    Then status 400

# -- Update Electronic piece with new location and delete holding -- #
  Scenario: Update Electronic piece with holding deletion and in the piece there is location reference
    Given path 'orders/pieces'
    * configure headers = headersUser
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def electronicPiecesForUpdate = $.pieces[?(@.format == 'Electronic')]
    * def electronicPieceForUpdate = electronicPiecesForUpdate[0]
    * set electronicPieceForUpdate.locationId = newElectronicCreatedHoldingIdFirstUpdate
    * remove electronicPieceForUpdate.holdingId

    * print 'Update Electronic piece without holding deletion'
    Given path 'orders/pieces', electronicPieceForUpdate.id
    * configure headers = headersUser
    And  request electronicPieceForUpdate
    When method PUT
    Then status 204

    Given path 'orders/pieces'
    * configure headers = headersUser
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def electronicPiecesForUpdateFirstUpdate = $.pieces[?(@.format == 'Electronic')]
    * def electronicPieceForUpdateFirstUpdate = electronicPiecesForUpdateFirstUpdate[0]
    And match electronicPieceForUpdateFirstUpdate.locationId == '#notpresent'
    And match electronicPieceForUpdateFirstUpdate.holdingId == '#present'
    * def newElectronicCreatedHoldingIdFirstUpdate = electronicPieceForUpdateFirstUpdate.holdingId
    * print 'FirstUpdate holding reference ' + newElectronicCreatedHoldingIdFirstUpdate


    * print 'Second Update Electronic piece with holding deletion'
    Given path 'orders/pieces', electronicPieceForUpdateFirstUpdate.id
    * set electronicPieceForUpdateFirstUpdate.locationId = newElectronicCreatedHoldingIdSecondUpdate
    * remove electronicPieceForUpdateFirstUpdate.holdingId
    * configure headers = headersUser
    And  request electronicPieceForUpdateFirstUpdate
    And param deleteHolding = true
    When method PUT
    Then status 204


    Given path 'orders/pieces'
    * configure headers = headersUser
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 2
    * def electronicPiecesAfterUpdateSecondUpdate = $.pieces[?(@.format == 'Electronic')]
    * def electronicPieceAfterUpdateSecondUpdate =  electronicPiecesAfterUpdateSecondUpdate[0]
    And assert electronicPieceAfterUpdateSecondUpdate.receivingStatus == 'Expected'
    And match electronicPieceAfterUpdateSecondUpdate.itemId == '#notpresent'
    * def newElectronicCreatedHoldingIdSecondUpdate = electronicPieceAfterUpdateSecondUpdate.holdingId
    * def physicalPiecesAfterUpdateSecondUpdate = $.pieces[?(@.format == 'Physical')]
    * def physicalPieceAfterUpdateSecondUpdate = physicalPiecesAfterUpdateSecondUpdate[0]
    And match physicalPieceAfterUpdateSecondUpdate.locationId == '#notpresent'
    And assert physicalPieceAfterUpdateSecondUpdate.receivingStatus == 'Expected'
    * print 'Second update holding id ' + newElectronicCreatedHoldingIdSecondUpdate

    * print 'Check holding should be deleted, because flag "deleteHolding" was true and no exist item or pieces'
    Given path 'holdings-storage/holdings', newElectronicCreatedHoldingIdSecondUpdate
    * configure headers = headersAdmin
    When method GET
    Then status 200


    * print 'Check holding should be deleted, because flag "deleteHolding" was true and no exist item or pieces'
    Given path 'holdings-storage/holdings', newElectronicCreatedHoldingIdFirstUpdate
    * configure headers = headersAdmin
    When method GET
    Then status 404

    * print 'Check order and transaction after Electronic piece update'
    Given path 'orders/composite-orders', orderId
    * configure headers = headersUser
    When method GET
    Then status 200
    * def poLine = $.compositePoLines[0]
    And match $.workflowStatus == 'Open'
    And match $.totalItems == 2
    And match $.totalEstimatedPrice == 7.0
    And match poLine.cost.quantityElectronic == 1
    And match poLine.cost.quantityPhysical == 1
    * def physicalLocationsAfterUpdate = $.compositePoLines[0].locations[?(@.quantityPhysical == 1)]
    * def physicalLocationAfterUpdate = physicalLocationsAfterUpdate[0]
    And match physicalLocationAfterUpdate.holdingId == initialHoldingId
    And match physicalLocationAfterUpdate.quantity == 1
    And match physicalLocationAfterUpdate.quantityPhysical == 1
    * def electronicalLocationsAfterUpdate = $.compositePoLines[0].locations[?(@.quantityElectronic == 1)]
    * def electronicalLocationAfterUpdate = electronicalLocationsAfterUpdate[0]
    And match electronicalLocationAfterUpdate.holdingId == newElectronicCreatedHoldingIdSecondUpdate
    And match electronicalLocationAfterUpdate.quantity == 1
    And match electronicalLocationAfterUpdate.quantityElectronic == 1


    * print 'Check encumbrances initial value'
    Given path 'finance/transactions'
    * configure headers = headersAdmin
    And param query = 'transactionType==Encumbrance and encumbrance.sourcePurchaseOrderId==' + orderId
    When method GET
    And match $.totalRecords == 1
    * def encumbranceTr = $.transactions[0]
    And assert encumbranceTr.amount == 7.0
    And assert encumbranceTr.encumbrance.initialAmountEncumbered == 7.0
    And assert encumbranceTr.encumbrance.status == 'Unreleased'
