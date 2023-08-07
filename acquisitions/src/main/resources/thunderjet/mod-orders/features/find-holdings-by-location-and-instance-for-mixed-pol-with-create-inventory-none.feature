@parallel=false
# for https://issues.folio.org/browse/MODORDERS-902
Feature: find-holdings-by-location-and-instance-for-mixed-pol

  Background:
    * url baseUrl
#    * callonce dev {tenant: 'testorders'}
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
    * def orderId1 = callonce uuid3
    * def orderId2 = callonce uuid4
    * def poLineId1 = callonce uuid5
    * def poLineId2 = callonce uuid6
    * def createOrder = read('classpath:thunderjet/mod-orders/reusable/create-order.feature')
    * def createOrderLine = read('classpath:thunderjet/mod-orders/reusable/create-order-line.feature')
    * def openOrder = read('classpath:thunderjet/mod-orders/reusable/open-order.feature')

  Scenario: Create finances
    * configure headers = headersAdmin
    * call createFund { 'id': '#(fundId)'}
    * call createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}

  Scenario: Create first order
    * call createOrder { id: #(orderId1), orderType: 'One-Time', vendor: '#(globalVendorId)'}

  Scenario: Create first mixed order line
    * call createOrderLine { id: #(poLineId1), orderId: #(orderId1), fundId: #(fundId), createInventory: 'None'}

  Scenario: Open the first order
    * callonce openOrder { orderId: "#(orderId1)" }

  Scenario: Check inventory and order items after open first order
    * print 'Get the instanceId and holdingId from the po line'
    Given path 'orders/order-lines', poLineId1
    * configure headers = headersUser
    When method GET
    Then status 200
    * def instanceId = response.instanceId
    * def holdingId = response.locations[0].holdingId
    * print 'Check items'

    Given path 'holdings-storage/holdings'
    * configure headers = headersAdmin
    And param query = 'instanceId==' + instanceId
    When method GET
    And match $.totalRecords == 1

    Given path 'inventory/items-by-holdings-id'
    * configure headers = headersAdmin
    And param query = 'holdingsRecordId==' + holdingId
    When method GET
    And match $.totalRecords == 1

  Scenario: Create second order
    * call createOrder { id: #(orderId2), orderType: 'One-Time', vendor: '#(globalVendorId)'}

  Scenario: Create second mixed order line
    * call createOrderLine { id: #(poLineId2), orderId: #(orderId2), fundId: #(fundId), createInventory: 'Instance'}

  Scenario: Open the second order
    * callonce openOrder { orderId: "#(orderId2)" }


  Scenario: Check inventory and order items after open second order
    * print 'Get the instanceId and holdingId from the po line'
    Given path 'orders/order-lines', poLineId2
    * configure headers = headersUser
    When method GET
    Then status 200
    * def instanceId = response.instanceId
    * def holdingId = response.locations[0].holdingId
    * print 'Check items'

    Given path 'holdings-storage/holdings'
    * configure headers = headersAdmin
    And param query = 'instanceId==' + instanceId
    When method GET
    And match $.totalRecords == 1

    Given path 'inventory/items-by-holdings-id'
    * configure headers = headersAdmin
    And param query = 'holdingsRecordId==' + holdingId
    When method GET
    And match $.totalRecords == 1