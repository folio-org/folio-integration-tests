@parallel=false
Feature: Create fives pieces for an open order

  Background:
    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId1 = callonce uuid4
    * def poLineId2 = callonce uuid5
    * def poLineId3 = callonce uuid6
    * def poLineId4 = callonce uuid7
    * def poLineId5 = callonce uuid8
    * def pieceId1 = callonce uuid9
    * def pieceId2 = callonce uuid10
    * def pieceId3 = callonce uuid11
    * def pieceId4 = callonce uuid12
    * def pieceId5 = callonce uuid13

    * def createOrder = read('../reusable/create-order.feature')
    * def createOrderLine = read('../reusable/create-order-line.feature')
    * def openOrder = read('../reusable/open-order.feature')
    * def getOrderLineTitleId = read('../reusable/get-order-line-title-id.feature')
    * def createPiece = read('../reusable/create-piece.feature')

    * configure headers = headersUser

  Scenario: Create finances
    * configure headers = headersAdmin
    * callonce createFund { 'id': '#(fundId)'}
    * callonce createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}

  Scenario: Create order
    * callonce createOrder { orderId: "#(orderId)" }

  Scenario: Create order lines
    * callonce createOrderLine { orderId: "#(orderId)", poLineId: "#(poLineId1)", fundId: "#(fundId)" }
    * callonce createOrderLine { orderId: "#(orderId)", poLineId: "#(poLineId2)", fundId: "#(fundId)" }
    * callonce createOrderLine { orderId: "#(orderId)", poLineId: "#(poLineId3)", fundId: "#(fundId)" }
    * callonce createOrderLine { orderId: "#(orderId)", poLineId: "#(poLineId4)", fundId: "#(fundId)" }
    * callonce createOrderLine { orderId: "#(orderId)", poLineId: "#(poLineId5)", fundId: "#(fundId)" }

  Scenario: Open order
    * callonce openOrder { orderId: "#(orderId)" }

  Scenario: Get titles and create pieces
    * callonce getOrderLineTitleId { poLineId: "#(poLineId1)" }
    * def titleId1 = titleId
    * callonce getOrderLineTitleId { poLineId: "#(poLineId2)" }
    * def titleId2 = titleId
    * callonce getOrderLineTitleId { poLineId: "#(poLineId3)" }
    * def titleId3 = titleId
    * callonce getOrderLineTitleId { poLineId: "#(poLineId4)" }
    * def titleId4 = titleId
    * callonce getOrderLineTitleId { poLineId: "#(poLineId5)" }
    * def titleId5 = titleId
    * call createPiece { pieceId: "#(pieceId1)", poLineId: "#(poLineId1)", titleId: "#(titleId1)" }
    * call createPiece { pieceId: "#(pieceId2)", poLineId: "#(poLineId2)", titleId: "#(titleId2)" }
    * call createPiece { pieceId: "#(pieceId3)", poLineId: "#(poLineId3)", titleId: "#(titleId3)" }
    * call createPiece { pieceId: "#(pieceId4)", poLineId: "#(poLineId4)", titleId: "#(titleId4)" }
    * call createPiece { pieceId: "#(pieceId5)", poLineId: "#(poLineId5)", titleId: "#(titleId5)" }

  Scenario: Check budget
    Given path '/finance/budgets'
    And param query = 'fundId==' + fundId
    When method GET
    Then status 200

    * def budget = response.budgets[0]

    And match budget.available == 9990
    And match budget.expenditures == 0
    And match budget.encumbered == 10
    And match budget.awaitingPayment == 0
    And match budget.unavailable == 10
