# For MODORDERS-902
Feature: check-holding-instance-creation-with-createInventory-options

  Background:
    * print karate.info.scenarioName
    * url baseUrl

    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken
    * callonce login testUser
    * def okapitokenUser = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json', 'x-okapi-tenant': '#(testTenant)' }

    * callonce variables
    * def fundId = callonce uuid1
    * def budgetId = callonce uuid2

    ## Prepare finances
    * configure headers = headersAdmin
    * callonce createFund { 'id': '#(fundId)' }
    * callonce createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)' }
    * configure headers = headersUser

  @Positive
  Scenario: Verify holding NOT being created when createInventory: None
    * def orderId = call uuid
    * def poLineId = call uuid
    
    * def v = call createOrder { id: #(orderId), orderType: 'One-Time', vendor: '#(globalVendorId)'}
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId), createInventory: 'None'}
    * def v = call openOrder { id: #(orderId)}

    # Verify instance is not being created
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == '#notpresent'

  @Positive
  Scenario: Verify holding NOT being created when createInventory: Instance Create first mixed order line
    * def orderId = call uuid
    * def poLineId = call uuid
    
    * def v = call createOrder { id: #(orderId), orderType: 'One-Time', vendor: '#(globalVendorId)'}
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId), createInventory: 'Instance'}
    * def v = call openOrder { id: #(orderId)}

    # Verify holding is not being created
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId != null
    And response.locations[0].holdingId == '#notpresent'
    * def instanceId = response.instanceId

    Given path 'holdings-storage/holdings'
    * configure headers = headersAdmin
    And param query = 'instanceId==' + instanceId
    When method GET
    And match $.totalRecords == 0

  @Positive
  Scenario: Verify Instance, Holding, Item creation when createInventory: Instance, Holding, Item
    * def orderId = call uuid
    * def poLineId = call uuid
    
    * def v = call createOrder { id: #(orderId), orderType: 'One-Time', vendor: '#(globalVendorId)'}
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId), createInventory: 'Instance, Holding, Item'}
    * def v = call openOrder { id: #(orderId)}

    # Verify instance, holding, item creation
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def instanceId = response.instanceId
    * def holdingId = response.locations[0].holdingId

    Given path 'holdings-storage/holdings'
    * configure headers = headersAdmin
    And param query = 'instanceId==' + instanceId
    When method GET
    And match $.totalRecords == 1

    Given path 'inventory/items-by-holdings-id'
    And param query = 'holdingsRecordId==' + holdingId
    When method GET
    And match $.totalRecords == 1