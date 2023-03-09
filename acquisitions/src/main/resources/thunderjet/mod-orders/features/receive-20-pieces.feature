@parallel=false
# for https://issues.folio.org/browse/MODORDERS-862
Feature: Receive 20 pieces

  Background:
    * print karate.info.scenarioName

    * url baseUrl

    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*' }

    * configure headers = headersUser

    * callonce variables

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')
    * def createTitle = read('classpath:thunderjet/mod-orders/reusable/create-title.feature')
    * def createPiece = read('classpath:thunderjet/mod-orders/reusable/create-piece.feature')
    * def receivePiece = read('classpath:thunderjet/mod-orders/reusable/receive-piece.feature')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4


  Scenario: Create finances
    * configure headers = headersAdmin
    * def v = call createFund { 'id': '#(fundId)' }
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)' }


  Scenario: Create an order
    * def v = callonce createOrder { id: #(orderId) }


  Scenario: Create an order line with isPackage
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.isPackage = true
    * set poLine.checkinItems = true
    * set poLine.physical.createInventory = 'Instance, Holding, Item'
    * set poLine.fundDistribution[0].fundId = fundId

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201


  Scenario: Open the order
    * def v = callonce openOrder { orderId: "#(orderId)" }


  Scenario: Receive 20 pieces
    * def createTitleParameters = []
    * def createPieceParameters = []
    * def receivePieceParameters = []
    * def createParameterArrays =
"""
function() {
  for (let i=0; i<20; i++) {
    const titleId = uuid();
    const pieceId = uuid();
    createTitleParameters.push({ titleId, poLineId });
    createPieceParameters.push({ pieceId, poLineId, titleId });
    receivePieceParameters.push({ pieceId, poLineId });
  }
}
"""
    * eval createParameterArrays()
    * def v = call createTitle createTitleParameters
    * def v = call createPiece createPieceParameters
    * def v = call receivePiece receivePieceParameters


  Scenario: Check number of pieces and receivingStatus
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    And param limit = 30
    When method GET
    Then status 200
    And match $.totalRecords == 20
    And match $.pieces[?(@.receivingStatus=='Received')] == '#[20]'
