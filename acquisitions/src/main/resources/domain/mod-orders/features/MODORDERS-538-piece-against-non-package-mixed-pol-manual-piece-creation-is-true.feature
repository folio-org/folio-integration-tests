@parallel=false
# for https://issues.folio.org/browse/MODORDERS-538
Feature: Should create and delete pieces for non package mixed POL with quantity POL updates when manual is true

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


  Scenario: Create finances
    # this is needed for instance if a previous test does a rollover which changes the global fund
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}

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


  Scenario: Create an mixed order line with isPackage=false and manual piece creation is true
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-mixed-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.checkinItems = true
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
    And match $.totalRecords == 0


    * print 'Check if pieces were created when the order was opened'
    Given path 'orders/pieces'
    * configure headers = headersUser
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 0

    * print 'Check holdings'
    Given path 'holdings-storage/holdings', initialHoldingId
    * configure headers = headersAdmin
    When method GET
    Then status 200
    And assert response.id == initialHoldingId


  Scenario: Create set of pieces
    * configure headers = headersAdmin
    Given path 'orders/titles'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    * def title = $.titles[0]
    * def titleId = title.id

    Given path 'orders/pieces'
    * configure headers = headersUser
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
    * call pause 900

    Given path 'orders/pieces'
    * configure headers = headersUser
    And request
    """
    {
      format: "Physical",
      holdingId: "#(initialHoldingId)",
      poLineId: "#(poLineId)",
      titleId: "#(titleId)"
    }
    """
    And param createItem = true
    When method POST
    Then status 201
    * call pause 900

    Given path 'orders/pieces'
    * configure headers = headersUser
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
    * configure headers = headersUser
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
    * call pause 900

    Given path 'orders/pieces'
    * configure headers = headersUser
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
    * call pause 900

  Scenario: Check inventory and order items after adding set of pieces
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
    And param query = 'purchaseOrderLineIdentifier==' + poLineId + ' and holdingsRecordId==' + initialHoldingId
    When method GET
    And match $.totalRecords == 2


    * print 'Check if pieces were created when the order was opened'
    Given path 'orders/pieces'
    * configure headers = headersUser
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 5

    * print 'Check holdings'
    Given path 'holdings-storage/holdings', initialHoldingId
    * configure headers = headersAdmin
    When method GET
    Then status 200
    And assert response.id == initialHoldingId

  Scenario: Check order and transaction after adding set of pieces
    Given path 'orders/composite-orders', orderId
    * configure headers = headersUser
    When method GET
    Then status 200
    * def orderResponse = $
    * def poLine = orderResponse.compositePoLines[0]
    And match orderResponse.workflowStatus == 'Open'
    And match orderResponse.totalItems == 2
    And match orderResponse.totalEstimatedPrice == 7.0
    And match poLine.cost.quantityElectronic == 1
    And match poLine.cost.quantityPhysical == 1
    And match poLine.locations == '#[1]'

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

   #-- DELETE Electronic piece -- #
  Scenario: Delete Physical piece with item and with holding deletion
    * print 'Delete piece With Item And initially Location in the piece with holding deletion'
    Given path 'orders/pieces', pieceIdWithItemAndLocation
    * configure headers = headersUser
    When method GET
    Then status 200
    * def pieceForDelete = $
    * def pieceItemId = $.itemId
    * def pieceHoldingId = $.holdingId

    * print 'Delete piece With Item And initially Location in the piece with holding deletion'
    Given path 'orders/pieces', pieceIdWithItemAndLocation
    * configure headers = headersUser
    And param deleteHolding = true
    When method DELETE
    Then status 204
    * call pause 1000

    * print 'Check item should be deleted'
    Given path 'inventory/items', pieceItemId
    * configure headers = headersAdmin
    When method GET
    Then status 404

    * print 'Check Electronic piece should be deleted'
    Given path 'orders/pieces', pieceIdWithItemAndLocation
    * configure headers = headersUser
    When method GET
    Then status 404
    * call pause 1000

    * print 'Check holding should be deleted, because flag "deleteHolding" was provided and not existing items'
    Given path 'holdings-storage/holdings', pieceHoldingId
    * configure headers = headersAdmin
    When method GET
    Then status 404
    * call pause 900

  Scenario: Check order and transaction after Physical piece and connected holding and item deletion
    Given path 'orders/composite-orders', orderId
    * configure headers = headersUser
    When method GET
    Then status 200
    * def orderResponse = $
    * def poLine = orderResponse.compositePoLines[0]
    And match orderResponse.workflowStatus == 'Open'
    And match orderResponse.totalItems == 2
    And match orderResponse.totalEstimatedPrice == 7.0
    And match poLine.cost.quantityElectronic == 1
    And match poLine.cost.quantityPhysical == 1
    And match poLine.locations == '#[1]'

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

   #-- DELETE Electronic piece -- #
  Scenario: Delete Electronic piece without item and with holding deletion, where still connected items
    * print 'Delete Electronic piece without item and with holding deletion, where still connected items'
    Given path 'orders/pieces', pieceIdWithoutItemAndHolding
    * configure headers = headersUser
    When method GET
    Then status 200
    * def pieceForDelete = $
    * def pieceItemId = $.itemId
    * def pieceHoldingId = $.holdingId

    * print 'Delete piece With Item And initially Global holding in the piece with holding deletion'
    Given path 'orders/pieces', pieceIdWithoutItemAndHolding
    * configure headers = headersUser
    And param deleteHolding = true
    When method DELETE
    Then status 204
    * call pause 1000

    * print 'Check Electronic piece should be deleted'
    Given path 'orders/pieces', pieceIdWithoutItemAndHolding
    * configure headers = headersUser
    When method GET
    Then status 404

    * print 'Check holding should not be deleted and flag "deleteHolding" was provided but existing items'
    Given path 'holdings-storage/holdings', pieceHoldingId
    * configure headers = headersAdmin
    When method GET
    Then status 200
    * call pause 900

  Scenario: Check order and transaction after Electronic piece deletion without connected holding deletion
    Given path 'orders/composite-orders', orderId
    * configure headers = headersUser
    When method GET
    Then status 200
    * def orderResponse = $
    * def poLine = orderResponse.compositePoLines[0]
    And match orderResponse.workflowStatus == 'Open'
    And match orderResponse.totalItems == 2
    And match orderResponse.totalEstimatedPrice == 7.0
    And match poLine.cost.quantityElectronic == 1
    And match poLine.cost.quantityPhysical == 1
    And match poLine.locations == '#[1]'

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
