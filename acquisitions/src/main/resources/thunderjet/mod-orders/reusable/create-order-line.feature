Feature: Create order line
  # parameters: id, orderId, fundId, listUnitPrice

  Background:
    * url baseUrl

  Scenario: createOrderLine
    * def listUnitPrice = karate.get('listUnitPrice', 1.0)
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * set poLine.id = id
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.cost.listUnitPrice = listUnitPrice
    * set poLine.cost.poLineEstimatedPrice = listUnitPrice

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201
