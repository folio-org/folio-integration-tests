@parallel=false
# created for https://issues.folio.org/browse/MODORDERS-528
Feature: Open order failure side effects

  Background:
    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*'  }
    * configure headers = headersUser

    * callonce variables

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4
    * def titleOrPackage = callonce uuid5


  Scenario: Create a fund without a budget
    * print 'Create a fund without a budget'
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)', 'ledgerId': '#(globalLedgerWithRestrictionsId)' }
    # no budget creation yet, to make open order fail


  Scenario: Create an order
    * print 'Create an order'
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
    * print 'Create an order line'
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.cost.listUnitPrice = 10
    * set poLine.cost.poLineEstimatedPrice = 10
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.titleOrPackage = titleOrPackage

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201


  Scenario: Try to open the order
    * print 'Try to open the order'
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 404

    # We are checking that inventory records were not created during the failed open order operation
    * print 'Check instances'
    Given path 'inventory/instances'
    And param query = 'title==' + titleOrPackage
    When method GET
    And match $.totalRecords == 0

    * print 'Check pieces'
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 0

    * print 'Check items'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 0


  Scenario: Create a budget with insufficient allocation
    * configure headers = headersAdmin
    * call createBudget { 'id': '#(budgetId)', 'allocated': 5, 'fundId': '#(fundId)'}


  Scenario: Try to open the order again
    * print 'Try to open the order again'
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 422

    * print 'Check instances'
    Given path 'inventory/instances'
    And param query = 'title==' + titleOrPackage
    When method GET
    And match $.totalRecords == 0

    * print 'Check pieces'
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 0

    * print 'Check items'
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 0
