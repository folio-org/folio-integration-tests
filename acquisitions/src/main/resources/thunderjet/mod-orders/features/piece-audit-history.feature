@parallel=false
Feature: Piece audit history

  Background:
    * print karate.info.scenarioName

    * url baseUrl
#    * callonce dev {tenant: 'testorders1'}
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-audit-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4

    * configure retry = { count: 5, interval: 5000 }

  Scenario: Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: #(fundId) }
    * def v = call createBudget { id: #(budgetId), fundId: #(fundId), allocated: 1000 }

  Scenario: Create an order
    * def v = call createOrder { id: #(orderId) }

  Scenario: Create an order line
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId) }

  Scenario: Open the order
    * def v = call openOrder { orderId: #(orderId) }

  Scenario: First piece update
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def piece = $.pieces[0]
    * def pieceId = piece.id

    * set piece.copyNumber = '111'

    Given path 'orders/pieces', pieceId
    And request piece
    When method PUT
    Then status 204

  Scenario: Second piece update
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def piece = $.pieces[0]
    * def pieceId = piece.id

    * set piece.enumeration = '333'

    Given path 'orders/pieces', pieceId
    And request piece
    When method PUT
    Then status 204

  Scenario: Check main audit history for piece
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def pieceId = $.pieces[0].id

    Given path 'audit-data/acquisition/piece', pieceId
    When method GET
    Then status 200
    And retry until response.totalItems > 0

    Given path 'audit-data/acquisition/piece', pieceId
    When method GET
    Then status 200
    And match $.totalItems == 3

  Scenario: Check audit statuses history for piece
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def pieceId = $.pieces[0].id

    Given path 'audit-data/acquisition/piece', pieceId, 'status-change-history'
    When method GET
    Then status 200
    And retry until response.totalItems > 0

    Given path 'audit-data/acquisition/piece', pieceId, 'status-change-history'
    When method GET
    Then status 200
    And match $.totalItems == 1

  Scenario: First status update of piece
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    * def piece = $.pieces[0]
    * def pieceId = piece.id

    * set piece.receivingStatus = 'Claim delayed'

    Given path 'orders/pieces', pieceId
    And request piece
    When method PUT
    Then status 204

  Scenario: Second status update of piece
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def piece = $.pieces[0]
    * def pieceId = piece.id

    * set piece.receivingStatus = 'Claim sent'

    Given path 'orders/pieces', pieceId
    And request piece
    When method PUT
    Then status 204

  Scenario: Check main audit history for piece
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def pieceId = $.pieces[0].id

    Given path 'audit-data/acquisition/piece', pieceId
    When method GET
    Then status 200
    And retry until response.totalItems > 0

    Given path 'audit-data/acquisition/piece', pieceId
    When method GET
    Then status 200
    And match $.totalItems == 5

  Scenario: Check audit statuses history for piece
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def pieceId = $.pieces[0].id

    Given path 'audit-data/acquisition/piece', pieceId, 'status-change-history'
    When method GET
    Then status 200
    And retry until response.totalItems > 0

    Given path 'audit-data/acquisition/piece', pieceId, 'status-change-history'
    When method GET
    Then status 200
    And match $.totalItems == 3
