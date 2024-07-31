Feature: rtac from order piece tests
  Background:
    * url baseUrl
    * call login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json'  }

    * def variables = karate.read('util/order/variables.feature')
    * def createFund = karate.read('util/order/create-fund.feature')
    * def createBudget = karate.read('util/order/create-budget.feature')

    * callonce read('util/order/inventory.feature')
    * callonce read('util/order/configuration.feature')
    * callonce read('util/order/finances.feature')
    * callonce read('util/order/organizations.feature')
    * callonce read('util/order/orders.feature')
    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4
    * def initialInstanceId = globalInstanceId1
    * def initialHoldingId = globalHoldingId3

  Scenario: Create finances
    # this is needed for instance if a previous test does a rollover which changes the global fund
    * configure headers = headers
    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}

  Scenario: Create an order
    * configure headers = headersUser
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
    * def poLine = read('classpath:samples/orders/order-line-entity-request.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.instanceId = initialInstanceId
    * set poLine.isPackage = false
    * set poLine.fundDistribution[0].fundId = fundId
    * remove poLine.locations[0].locationId
    * set poLine.locations[0].holdingId = initialHoldingId
    Given path 'orders/order-lines'
    * configure headers = headersUser
    And request poLine
    When method POST
    Then status 201
    * def createdLine = $
    And match $.instanceId == initialInstanceId

  Scenario: Open the order
    Given path 'orders/composite-orders', orderId
    * configure headers = headersUser
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204
