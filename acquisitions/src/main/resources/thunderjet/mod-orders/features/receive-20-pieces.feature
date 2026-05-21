# For MODORDERS-862
Feature: Receive 20 pieces

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

    * def receivePiece = read('classpath:thunderjet/mod-orders/reusable/receive-piece.feature')


  Scenario: Receive 20 pieces
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Create finances
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 10000, fundId: '#(fundId)' }

    # 2. Create an order
    * configure headers = headersUser
    * def v = call createOrder { id: #(orderId) }

    # 3. Create an order line with isPackage
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', isPackage: true, checkinItems: true }

    # 4. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Receive 20 pieces
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

    # 6. Check number of pieces and receivingStatus
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    And param limit = 30
    When method GET
    Then status 200
    And match $.totalRecords == 20
    And match $.pieces[?(@.receivingStatus=='Received')] == '#[20]'
