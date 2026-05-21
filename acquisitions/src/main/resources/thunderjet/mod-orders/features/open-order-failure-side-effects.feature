# For MODORDERS-528
@parallel=false
Feature: Open order failure side effects

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

    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2
    * def orderId = callonce uuid3
    * def poLineId = callonce uuid4
    * def titleOrPackage = callonce uuid5


  Scenario: Create a fund without a budget
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)', ledgerId: '#(globalLedgerWithRestrictionsId)' }
    # no budget creation yet, to make open order fail


  Scenario: Create an order
    * def v = call createOrder { id: '#(orderId)' }


  Scenario: Create an order line
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', listUnitPrice: 10, titleOrPackage: '#(titleOrPackage)' }


  Scenario: Try to open the order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 422

    # We are checking that inventory records were not created during the failed open order operation
    * configure headers = headersAdmin
    * print 'Check instances'
    Given path 'inventory/instances'
    And param query = 'title==' + titleOrPackage
    When method GET
    And match $.totalRecords == 0

    * print 'Check pieces'
    * configure headers = headersUser
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 0

    * print 'Check items'
    * configure headers = headersAdmin
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 0


  Scenario: Create a budget with insufficient allocation
    * configure headers = headersAdmin
    * def v = call createBudget { 'id': '#(budgetId)', 'allocated': 5, 'fundId': '#(fundId)' }


  Scenario: Try to open the order again
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
    * configure headers = headersAdmin
    Given path 'inventory/instances'
    And param query = 'title==' + titleOrPackage
    When method GET
    And match $.totalRecords == 0

    * print 'Check pieces'
    * configure headers = headersUser
    Given path 'orders/pieces'
    And param query = 'poLineId==' + poLineId
    When method GET
    Then status 200
    And match $.totalRecords == 0

    * print 'Check items'
    * configure headers = headersAdmin
    Given path 'inventory/items'
    And param query = 'purchaseOrderLineIdentifier==' + poLineId
    When method GET
    And match $.totalRecords == 0
