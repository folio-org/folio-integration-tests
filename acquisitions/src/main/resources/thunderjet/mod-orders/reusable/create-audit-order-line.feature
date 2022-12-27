Feature: Create order line
  # parameters: id, orderId, fundId

  Background:
    * url baseUrl

  Scenario: createOrderLine
    * def poLine = read('classpath:samples/mod-orders/orderLines/order-line-audit.json')
    * set poLine.id = id
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201
