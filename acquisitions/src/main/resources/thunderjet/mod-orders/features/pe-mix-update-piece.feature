# For MODORDERS-1079, MODORDERS-1435
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


  @Positive
  Scenario: Update piece for default P/E mix
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    * print "Create finances"
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 1000, fundId: '#(fundId)', status: 'Active' }

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


  @Positive
  Scenario: Change the piece format, causing a cost update
    * def fundId = call uuid
    * def budgetId = call uuid
    * def orderId = call uuid
    * def poLineId = call uuid

    # 1. Prepare finances
    * print "1. Prepare finances"
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', fundId: '#(fundId)', allocated: 1000 }

    # 2. Create an order
    * print "2. Create an order"
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    # 3. Create an order line with a P/E mix
    * print "3. Create an order line with a P/E mix"
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-mixed-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    # 4. Open the order
    * print "4. Open the order"
    * def v = call openOrder { orderId: '#(orderId)' }

    # 5. Get the electronic piece
    * print '5. Get the electronic piece'
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId + ' AND format==Electronic'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    * def piece = $.pieces[0]

    # 6. Change the format to Physical
    * print '6. Change the format to Physical'
    * set piece.format = 'Physical'
    Given path 'orders/pieces', piece.id
    And request piece
    When method PUT
    Then status 204

    # 7. Check the po line
    * print '7. Check the po line'
    Given path 'orders/order-lines/', poLineId
    When method GET
    Then status 200
    And match $.cost.quantityPhysical == 2
    And match $.cost.quantityElectronic == 0
    And match $.cost.poLineEstimatedPrice == 8.0

    # 8. Check the budget encumbrance
    * print '8. Check the budget encumbrance'
    * configure headers = headersAdmin
    Given path '/finance/budgets', budgetId
    When method GET
    Then status 200
    And match $.encumbered == 8.0
