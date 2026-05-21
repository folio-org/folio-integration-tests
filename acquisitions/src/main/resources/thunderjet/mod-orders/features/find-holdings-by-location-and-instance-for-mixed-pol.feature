# For MODORDERS-871
@parallel=false
Feature: find-holdings-by-location-and-instance-for-mixed-pol

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
    * def orderId1 = callonce uuid3
    * def orderId2 = callonce uuid4
    * def poLineId1 = callonce uuid5
    * def poLineId2 = callonce uuid6

  Scenario: Create finances
    * configure headers = headersAdmin
    * def v = call createFund { id: '#(fundId)' }
    * def v = call createBudget { id: '#(budgetId)', allocated: 10000, fundId: '#(fundId)' }

  Scenario: Create first order
    * def v = call createOrder { id: '#(orderId1)' }

  Scenario: Create first mixed order line
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-mixed-order-line.json')
    * set poLine.id = poLineId1
    * set poLine.purchaseOrderId = orderId1
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.eresource.createInventory = 'Instance, Holding, Item'
    * set poLine.source = 'API'
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201
    * def createdLine = $
    * def poLineNumber = createdLine.createdLine

  Scenario: Open the first order
    * def v = call openOrder { orderId: '#(orderId1)' }

  Scenario: Check inventory and order items after open first order
    * print 'Get the instanceId and holdingId from the po line'
    Given path 'orders/order-lines', poLineId1
    When method GET
    Then status 200
    * def instanceId = response.instanceId
    * def holdingId = response.locations[0].holdingId
    * print 'Check items'

    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    And match $.totalRecords == 1

    Given path 'inventory/items-by-holdings-id'
    And param query = 'holdingsRecordId==' + holdingId
    When method GET
    And match $.totalRecords == 2

  Scenario: Create second order
    * def v = call createOrder { id: '#(orderId2)' }

  Scenario: Create second mixed order line
    * print 'Get the instanceId'
    Given path 'orders/order-lines', poLineId1
    When method GET
    Then status 200
    * def instanceId = response.instanceId

    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-mixed-order-line.json')
    * set poLine.id = poLineId2
    * set poLine.purchaseOrderId = orderId2
    * set poLine.instanceId = instanceId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.eresource.createInventory = 'Instance, Holding, Item'
    * set poLine.source = 'API'
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201
    * def createdLine = $
    * def poLineNumber = createdLine.createdLine

  Scenario: Open the second order
    * def v = call openOrder { orderId: '#(orderId2)' }

  Scenario: Check inventory and order items after open second order
    * print 'Get the instanceId and holdingId from the po line'
    Given path 'orders/order-lines', poLineId1
    When method GET
    Then status 200
    * def instanceId = response.instanceId
    * def holdingId = response.locations[0].holdingId
    * print 'Check items'

    * configure headers = headersAdmin
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    And match $.totalRecords == 1

    Given path 'inventory/items-by-holdings-id'
    And param query = 'holdingsRecordId==' + holdingId
    When method GET
    And match $.totalRecords == 4