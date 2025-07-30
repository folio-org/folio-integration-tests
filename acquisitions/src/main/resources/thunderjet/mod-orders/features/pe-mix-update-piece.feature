# For MODORDERS-1079
Feature: P/E mix update piece

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


  Scenario: Update piece for default P/E mix
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    * print "Create finances"
    * configure headers = headersAdmin
    * call createFund { id: '#(fundId)' }
    * call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }

    * print "Create an order"
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    * print "Create an order line with a P/E mix"
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-mixed-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    * print "Open the order"
    * def v = call openOrder { orderId: '#(orderId)' }

    * print 'Get the electronic piece'
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId + ' AND format==Electronic'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def piece = $.pieces[0]

    * print 'Update it without changing anything'
    Given path 'orders/pieces', piece.id
    And request piece
    When method PUT
    Then status 204
