# For MODORDERS-646
@parallel=false
Feature: Three fund distributions

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

    * def fundId1 = callonce uuid1
    * def fundId2 = callonce uuid2
    * def fundId3 = callonce uuid3
    * def budgetId1 = callonce uuid4
    * def budgetId2 = callonce uuid5
    * def budgetId3 = callonce uuid6
    * def orderId = callonce uuid7
    * def poLineId = callonce uuid8


  Scenario: Create funds and budgets
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId1)', ledgerId: '#(globalLedgerId)' }
    * def v = call createFund { id: '#(fundId2)', ledgerId: '#(globalLedgerId)' }
    * def v = call createFund { id: '#(fundId3)', ledgerId: '#(globalLedgerId)' }
    * def v = call createBudget { id: '#(budgetId1)', fundId: '#(fundId1)', allocated: 1000 }
    * def v = call createBudget { id: '#(budgetId2)', fundId: '#(fundId2)', allocated: 1000 }
    * def v = call createBudget { id: '#(budgetId3)', fundId: '#(fundId3)', allocated: 1000 }


  Scenario: Create a composite order
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201


  Scenario: Create an order line
    Given path 'orders/order-lines'

    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.cost.listUnitPrice = 90
    * set poLine.cost.poLineEstimatedPrice = 90
    * set poLine.fundDistribution[0] = { fundId:"#(fundId1)", code :"#(fundId1)", distributionType:"amount", value:30.0 }
    * set poLine.fundDistribution[1] = { fundId:"#(fundId2)", code :"#(fundId2)", distributionType:"amount", value:30.0 }
    * set poLine.fundDistribution[2] = { fundId:"#(fundId3)", code :"#(fundId3)", distributionType:"amount", value:30.0 }

    And request poLine
    When method POST
    Then status 201


  Scenario: Open the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 204

