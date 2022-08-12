# created for https://issues.folio.org/browse/MODORDERS-715
@parallel=false
Feature: Validate fund distribution for zero price

  Background:
    * print karate.info.scenarioName

    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')
    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')

    * def fundId1 = callonce uuid1
    * def budgetId1 = callonce uuid2
    * def fundId2 = callonce uuid3
    * def budgetId2 = callonce uuid4
    * def orderId = callonce uuid5
    * def poLineId1 = callonce uuid6
    * def poLineId2 = callonce uuid7


  Scenario: Prepare finances
    * configure headers = headersAdmin
    * def v = call createFund { id: #(fundId1) }
    * def v = call createBudget { id: #(budgetId1), fundId: #(fundId1), allocated: 1000 }
    * def v = call createFund { id: #(fundId2) }
    * def v = call createBudget { id: #(budgetId2), fundId: #(fundId2), allocated: 1000 }


  Scenario: Create an order
    * def v = call createOrder { id: #(orderId) }


  Scenario: Create an order line with a fund distribution using amounts
    * copy poLine = orderLineTemplate
    * set poLine.id = poLineId1
    * set poLine.purchaseOrderId = orderId
    * set poLine.cost.listUnitPrice = 0.0
    * set poLine.cost.poLineEstimatedPrice = 0.0
    * set poLine.fundDistribution[0] = { fundId: #(fundId1), code: #(fundId1), distributionType: "amount", value: 0.0 }
    * set poLine.fundDistribution[1] = { fundId: #(fundId2), code: #(fundId2), distributionType: "amount", value: 0.0 }

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201


  Scenario: Create an order line with a fund distribution using percentages
    * copy poLine = orderLineTemplate
    * set poLine.id = poLineId2
    * set poLine.purchaseOrderId = orderId
    * set poLine.cost.listUnitPrice = 0.0
    * set poLine.cost.poLineEstimatedPrice = 0.0
    * set poLine.fundDistribution[0] = { fundId: #(fundId1), code: #(fundId1), distributionType: "percentage", value: 50.0 }
    * set poLine.fundDistribution[1] = { fundId: #(fundId2), code: #(fundId2), distributionType: "percentage", value: 50.0 }

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201


  Scenario: Open the order
    * def v = call openOrder { orderId: #(orderId) }

