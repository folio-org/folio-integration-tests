# For https://issues.folio.org/browse/MODFISTO-260
# This should be executed with at least 5 threads
Feature: Create pieces for an open order in parallel

  Background:
    # This part is called once before scenarios are executed. It's important that all scenarios start at the same time,
    # so all scripts must be called with callonce.
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

    * def createOrder = read('reusable/create-order.feature')
    * def createOrderLine = read('reusable/create-order-line.feature')
    * def openOrder = read('reusable/open-order.feature')
    * def getOrderLineTitleId = read('reusable/get-order-line-title-id.feature')
    * def createPiece = read('reusable/create-piece.feature')

    * configure headers = headersAdmin
    * callonce createFund { 'id': '#(fundId)'}
    * callonce createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}
    * callonce createOrder { orderId: "#(orderId)" }
    * callonce createOrderLine { orderId: "#(orderId)", poLineId: "#(poLineId1)", fundId: "#(fundId)" }
    * callonce createOrderLine { orderId: "#(orderId)", poLineId: "#(poLineId2)", fundId: "#(fundId)" }
    * callonce createOrderLine { orderId: "#(orderId)", poLineId: "#(poLineId3)", fundId: "#(fundId)" }
    * callonce createOrderLine { orderId: "#(orderId)", poLineId: "#(poLineId4)", fundId: "#(fundId)" }
    * callonce createOrderLine { orderId: "#(orderId)", poLineId: "#(poLineId5)", fundId: "#(fundId)" }
    * callonce openOrder { orderId: "#(orderId)" }
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

    * configure headers = headersUser

  Scenario: Create pieces and check budget
    # it would be nice to put the contents of parallel-create-piece-2 here and use karate.afterFeature() to check the budget,
    # but errors are not reported with this method, so we have to use an additional feature file
    * call read('parallel-create-piece-2.feature')

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

