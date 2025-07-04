# created for https://issues.folio.org/browse/MODORDERS-715
Feature: Validate fund distribution for zero price

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

    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')

  @Positive
  Scenario: Validate fund distribution for zero price
    * def fundId1 = call uuid
    * def budgetId1 = call uuid
    * def fundId2 = call uuid
    * def budgetId2 = call uuid
    * def orderId = call uuid
    * def poLineId1 = call uuid
    * def poLineId2 = call uuid

    * print '1. Prepare finances'
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId1)' }
    * def v = call createBudget { id: '#(budgetId1)', fundId: '#(fundId1)', allocated: 1000 }
    * def v = call createFund { id: '#(fundId2)' }
    * def v = call createBudget { id: '#(budgetId2)', fundId: '#(fundId2)', allocated: 1000 }

    * print '2. Create an order'
    * configure headers = headersUser
    * def v = call createOrder { id: '#(orderId)' }

    * print '3. Create an order line with a fund distribution using amounts'
    * copy poLine = orderLineTemplate
    * set poLine.id = poLineId1
    * set poLine.purchaseOrderId = orderId
    * set poLine.cost.listUnitPrice = 0.0
    * set poLine.cost.poLineEstimatedPrice = 0.0
    * set poLine.fundDistribution[0] = { fundId: '#(fundId1)', code: '#(fundId1)', distributionType: "amount", value: 0.0 }
    * set poLine.fundDistribution[1] = { fundId: '#(fundId2)', code: '#(fundId2)', distributionType: "amount", value: 0.0 }

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    * print 'Create an order line with a fund distribution using percentages'
    * copy poLine = orderLineTemplate
    * set poLine.id = poLineId2
    * set poLine.purchaseOrderId = orderId
    * set poLine.cost.listUnitPrice = 0.0
    * set poLine.cost.poLineEstimatedPrice = 0.0
    * set poLine.fundDistribution[0] = { fundId: '#(fundId1)', code: '#(fundId1)', distributionType: "percentage", value: 50.0 }
    * set poLine.fundDistribution[1] = { fundId: '#(fundId2)', code: '#(fundId2)', distributionType: "percentage", value: 50.0 }

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201

    * print 'Open the order'
    * def v = call openOrder { orderId: '#(orderId)' }

