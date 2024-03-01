@parallel=false
# Created for MODORDERS-1049
# Related to MODORDERS-528 and open-order-failure-side-effects.feature
Feature: Open order failure with expenditure restrictions

  Background:
    * print karate.info.scenarioName
    * url baseUrl
    * callonce loginAdmin testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce loginRegularUser testUser
    * def okapitokenUser = okapitoken
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json' }
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': '*/*' }
    * configure headers = headersUser

    * callonce variables

    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')

    * def ledgerId = callonce uuid1
    * def fundId = callonce uuid2
    * def budgetId = callonce uuid3
    * def orderId = callonce uuid4
    * def poLineId = callonce uuid5
    * def titleOrPackage = callonce uuid6


  Scenario: Create finances
    * configure headers = headersAdmin
    * def v = call createLedger { id: "#(ledgerId)", fiscalYearId: "#(globalFiscalYearId)", restrictEncumbrance: false, restrictExpenditures: true }
    * def v = call createFund { id: "#(fundId)", ledgerId: "#(ledgerId)" }
    * def v = call createBudget { id: "#(budgetId)", fundId: "#(fundId)", allocated: 5 }


  Scenario: Create an order and line going over budget
    * def v = call createOrder { id: "#(orderId)" }
    * def v = call createOrderLine { id: "#(poLineId)", orderId: "#(orderId)", fundId: "#(fundId)", listUnitPrice: 10, titleOrPackage: titleOrPackage }


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


  Scenario: Check inventory records were not created during the failed open order operation
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


  Scenario: Change the order line amount
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def poLine = $
    * set poLine.cost.listUnitPrice = 5
    * set poLine.cost.poLineEstimatedPrice = 5

    Given path 'orders/order-lines', poLineId
    And request poLine
    When method PUT
    Then status 204


  Scenario: Try to open the order again
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    * set orderResponse.workflowStatus = 'Open'

    Given path 'orders/composite-orders', orderId
    And request orderResponse
    When method PUT
    Then status 204
