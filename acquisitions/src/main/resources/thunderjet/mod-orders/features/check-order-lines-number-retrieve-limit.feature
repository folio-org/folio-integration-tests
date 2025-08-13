@parallel=false
Feature: Check limit number of order lines which can be retrieved in scope of composite order.

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

    * def orderId = callonce uuid1
    * configure retry = { count: 999, interval: 130 }

  Scenario: Create One-time order
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

  Scenario: Update po line limit
    * configure headers = headersAdmin
    Given path 'orders-storage/settings'
    And param query = 'key==poLines-limit'
    When method GET
    Then status 200
    * def setting = $.settings[0]
    * set setting.value = '999'
    * def settingId = $.settings[0].id

    Given path 'orders-storage/settings', settingId
    And request setting
    When method PUT
    Then status 204

  Scenario: Create order line
    Given path 'orders/order-lines'

    * def orderLine = read('classpath:samples/mod-orders/orderLines/minimal-mixed-order-line.json')
    * set orderLine.purchaseOrderId = orderId
    * set orderLine.cost.quantityPhysical = '2'
    * set orderLine.cost.quantityElectronic = '2'
    * set orderLine.locations[1] = { 'quantity': '2', 'locationId': '#(globalLocationsId2)', 'quantityPhysical': '1', 'quantityElectronic': '1'}
    And retry until response.poLineNumber.contains('-510')
    And request orderLine
    When method POST
    Then status 201

  Scenario: Retrieve order
    Given path 'orders/composite-orders', orderId
    When method GET
    Then status 200

    * def orderResponse = $
    And match orderResponse.workflowStatus == 'Pending'
    And match orderResponse.totalItems == 2040
    And match orderResponse.totalEstimatedPrice == 7140



