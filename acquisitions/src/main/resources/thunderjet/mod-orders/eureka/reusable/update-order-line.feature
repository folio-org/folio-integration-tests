@ignore
Feature: Update order line
  # parameters: id, titleOrPackage?, paymentStatus?, receiptStatus?, listUnitPrice?

  Background:
    * url baseUrl

  Scenario: updateOrderLine
    Given path '/orders/order-lines', id
    When method GET
    Then status 200

    * def poLine = $
    * set poLine.titleOrPackage = karate.get('titleOrPackage', poLine.titleOrPackage)
    * set poLine.paymentStatus = karate.get('paymentStatus', poLine.paymentStatus)
    * set poLine.receiptStatus = karate.get('receiptStatus', poLine.receiptStatus)
    * set poLine.cost.listUnitPrice = karate.get('listUnitPrice', poLine.cost.listUnitPrice)
    * set poLine.cost.poLineEstimatedPrice = karate.get('listUnitPrice', poLine.cost.listUnitPrice)

    Given path 'orders/order-lines', id
    And request poLine
    When method PUT
    Then status 204
