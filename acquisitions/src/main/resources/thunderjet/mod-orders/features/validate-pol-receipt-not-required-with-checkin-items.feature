# For MODORDERS-1065
Feature: Validate PO Lines receipt status with check-in items

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

    * configure headers = headersAdmin
    * callonce createFund { 'id': '#(fundId)'}
    * callonce createBudget { 'id': '#(budgetId)', 'allocated': 10000, 'fundId': '#(fundId)'}
    * configure headers = headersUser

  @Negative
  Scenario: Create order and order line with check-in items false
    * def orderId = call uuid
    * def v = call createOrder { id: "#(orderId)" }

    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def poLineId = call uuid
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.receiptStatus = "Receipt Not Required"
    * set poLine.checkinItems = false
    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 422
    And match response.errors[*].code contains "receivingWorkflowIncorrectForReceiptNotRequired"
    And match response.errors[*].message contains "When POL's receipt status is 'Receipt Not Required', its receiving workflow must be set to 'Independent order and receipt quantity'"

  @Positive
  Scenario: Create order and order line with check-in items true
    * def orderId = call uuid
    * def v = call createOrder { id: "#(orderId)" }

    * def poLineId = call uuid
    * def v = call createOrderLine { id: '#(poLineId)', orderId: '#(orderId)', fundId: '#(fundId)', receiptStatus: 'Receipt Not Required', checkinItems: true }

  @Negative
  Scenario: Create composite order and order line and check-in items false
    * def po = read('classpath:samples/mod-orders/compositeOrders/po-listed-print-monograph.json')
    * remove po.poLines[1]
    * set po.poLines[0].fundDistribution[0].fundId = fundId
    * set po.poLines[0].fundDistribution[1].fundId = fundId
    * set po.poLines[0].receiptStatus = "Receipt Not Required"
    * set po.poLines[0].checkinItems = false

    Given path 'orders/composite-orders'
    And request po
    When method POST
    Then status 422
    And match response.errors[*].code contains "receivingWorkflowIncorrectForReceiptNotRequired"
    And match response.errors[*].message contains "When POL's receipt status is 'Receipt Not Required', its receiving workflow must be set to 'Independent order and receipt quantity'"

  @Positive
  Scenario: Create composite order and order line and check-in items true
    * def po = read('classpath:samples/mod-orders/compositeOrders/po-listed-print-monograph.json')
    * remove po.poLines[1]
    * set po.poLines[0].fundDistribution[0].fundId = fundId
    * set po.poLines[0].fundDistribution[1].fundId = fundId
    * set po.poLines[0].receiptStatus = "Receipt Not Required"
    * set po.poLines[0].checkinItems = true

    Given path 'orders/composite-orders'
    And request po
    When method POST
    Then status 201