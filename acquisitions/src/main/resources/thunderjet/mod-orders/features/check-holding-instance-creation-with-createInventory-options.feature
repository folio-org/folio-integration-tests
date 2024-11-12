# MODORDERS-902
Feature: check-holding-instance-creation-with-createInventory-options

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


  Scenario:  Prepare finances
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}


  Scenario: Verify holding NOT being created when createInventory: None
    * def orderId = call uuid
    * def poLineId = call uuid
    
    * def v = call createOrder { id: #(orderId), orderType: 'One-Time', vendor: '#(globalVendorId)'}
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId), createInventory: 'None'}
    * def v = call openOrder { id: #(orderId)}

    # Verify instance is not being created
    * configure headers = headersAdmin
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId == '#notpresent'


  Scenario: Verify holding NOT being created when createInventory: Instance Create first mixed order line
    * def orderId = call uuid
    * def poLineId = call uuid
    
    * def v = call createOrder { id: #(orderId), orderType: 'One-Time', vendor: '#(globalVendorId)'}
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId), createInventory: 'Instance'}
    * def v = call openOrder { id: #(orderId)}

    # Verify holding is not being created
    * configure headers = headersAdmin
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    And match $.instanceId != null
    And response.locations[0].holdingId == '#notpresent'
    * def instanceId = response.instanceId

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    And match $.totalRecords == 0


  Scenario: Verify Instance, Holding, Item creation when createInventory: Instance, Holding, Item
    * def orderId = call uuid
    * def poLineId = call uuid
    
    * def v = call createOrder { id: #(orderId), orderType: 'One-Time', vendor: '#(globalVendorId)'}
    * def v = call createOrderLine { id: #(poLineId), orderId: #(orderId), fundId: #(fundId), createInventory: 'Instance, Holding, Item'}
    * def v = call openOrder { id: #(orderId)}

    # Verify instance, holding, item creation
    * configure headers = headersAdmin
    Given path 'orders/order-lines', poLineId
    When method GET
    Then status 200
    * def instanceId = response.instanceId
    * def holdingId = response.locations[0].holdingId

    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    And match $.totalRecords == 1

    Given path 'inventory/items-by-holdings-id'
    And param query = 'holdingsRecordId==' + holdingId
    When method GET
    And match $.totalRecords == 1