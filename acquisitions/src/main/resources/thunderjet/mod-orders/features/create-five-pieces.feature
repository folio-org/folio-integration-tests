# For MODORDERS-681
Feature: Create fives pieces for an open order

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

    * def getOrderLineTitleId = read('classpath:thunderjet/mod-orders/reusable/get-order-line-title-id.feature')


  Scenario: Create fives pieces for an open order
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid
    * def poLineId3 = call uuid
    * def poLineId4 = call uuid
    * def poLineId5 = call uuid
    * def pieceId1 = call uuid
    * def pieceId2 = call uuid
    * def pieceId3 = call uuid
    * def pieceId4 = call uuid
    * def pieceId5 = call uuid

    # 1. Create finances
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 10000, fundId: '#(fundId)' }

    # 2. Create order
    * configure headers = headersUser
    * def v = call createOrder { id: "#(orderId)" }

    # 3. Create order lines
    * def v = call createOrderLine { id: "#(poLineId1)", orderId: "#(orderId)", fundId: "#(fundId)" }
    * def v = call createOrderLine { id: "#(poLineId2)", orderId: "#(orderId)", fundId: "#(fundId)" }
    * def v = call createOrderLine { id: "#(poLineId3)", orderId: "#(orderId)", fundId: "#(fundId)" }
    * def v = call createOrderLine { id: "#(poLineId4)", orderId: "#(orderId)", fundId: "#(fundId)" }
    * def v = call createOrderLine { id: "#(poLineId5)", orderId: "#(orderId)", fundId: "#(fundId)" }

    # 4. Open order
    * call openOrder { orderId: "#(orderId)" }

    # 5. Get titles and create pieces
    * call getOrderLineTitleId { poLineId: "#(poLineId1)" }
    * def titleId1 = titleId
    * call getOrderLineTitleId { poLineId: "#(poLineId2)" }
    * def titleId2 = titleId
    * call getOrderLineTitleId { poLineId: "#(poLineId3)" }
    * def titleId3 = titleId
    * call getOrderLineTitleId { poLineId: "#(poLineId4)" }
    * def titleId4 = titleId
    * call getOrderLineTitleId { poLineId: "#(poLineId5)" }
    * def titleId5 = titleId
    * def v = call createPiece { pieceId: "#(pieceId1)", poLineId: "#(poLineId1)", titleId: "#(titleId1)" }
    * def v = call createPiece { pieceId: "#(pieceId2)", poLineId: "#(poLineId2)", titleId: "#(titleId2)" }
    * def v = call createPiece { pieceId: "#(pieceId3)", poLineId: "#(poLineId3)", titleId: "#(titleId3)" }
    * def v = call createPiece { pieceId: "#(pieceId4)", poLineId: "#(poLineId4)", titleId: "#(titleId4)" }
    * def v = call createPiece { pieceId: "#(pieceId5)", poLineId: "#(poLineId5)", titleId: "#(titleId5)" }

    # 6. Check budget
    * configure headers = headersAdmin
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
