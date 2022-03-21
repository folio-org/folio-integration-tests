# created for MODORDERS-652
@parallel=false
Feature: Fund codes in open order error

  Background:
    * url baseUrl

    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }

    * configure headers = headersUser

    * callonce variables

    * def fundId1 = callonce uuid1
    * def fundId2 = callonce uuid2
    * def budgetId1 = callonce uuid3
    * def budgetId2 = callonce uuid4
    * def orderId = callonce uuid5
    * def poLineId = callonce uuid6

    * def fundCode = 'RESTRICTED-FUND'


  Scenario: Create funds and budgets
    * configure headers = headersAdmin
    # avoiding shared scope with def to avoid defining a fundCode variable and using it in the next call to createFund
    * def v = call createFund { id: '#(fundId1)', ledgerId: '#(globalLedgerWithRestrictionsId)', fundCode: '#(fundCode)' }
    * def v = call createBudget { id: '#(budgetId1)', fundId: '#(fundId1)', allocated: 100 }
    * def v = call createFund { id: '#(fundId2)', ledgerId: '#(globalLedgerId)' }
    * def v = call createBudget { id: '#(budgetId2)', fundId: '#(fundId2)', allocated: 100 }


  Scenario: Create composite order
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


  Scenario: Create order line
    Given path 'orders/order-lines'

    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].value = 50.0
    * set poLine.fundDistribution[0].fundId = fundId1
    * set poLine.fundDistribution[0].code = fundCode
    * set poLine.fundDistribution[1] = { fundId: '#(fundId2)', code: '#(fundId2)', distributionType: 'percentage', value: 50.0 }
    * set poLine.cost.listUnitPrice = 300
    * set poLine.cost.poLineEstimatedPrice = 300

    And request poLine
    When method POST
    Then status 201


  Scenario: Open order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def order = $
    * set order.workflowStatus = "Open"

    Given path 'orders/composite-orders', orderId
    And request order
    When method PUT
    Then status 422
    And match $.errors[0].code == 'fundCannotBePaid'
    And match $.errors[0].parameters[0].value == '[' + fundCode + ']'
