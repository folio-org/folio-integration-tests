@ignore
Feature: Create order lines
  # parameters: statusTable

  Background: createOrderLines
    * url baseUrl

  Scenario: Create order lines
    * print "Create Order Line, entry: ", __arg
    * def orderLineTemplate = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * copy poLine = orderLineTemplate
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.paymentStatus = __arg.paymentStatus
    * set poLine.receiptStatus = __arg.receiptStatus

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201
