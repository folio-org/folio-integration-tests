@ignore
Feature: Create order line
  # parameters: id, orderId, fundId, listUnitPrice, isPackage, titleOrPackage, paymentStatus, receiptStatus

  Background:
    * url baseUrl

  Scenario: createOrderLine
    * def id = karate.get('id', null)
    * def listUnitPrice = karate.get('listUnitPrice', 1.0)
    * def isPackage = karate.get('isPackage', false)
    * def poLine = read('classpath:samples/mod-orders/orderLines/minimal-order-line.json')
    * def titleOrPackage = karate.get('titleOrPackage', 'test')
    * def paymentStatus = karate.get('paymentStatus', null)
    * def receiptStatus = karate.get('receiptStatus', null)
    * def locations = karate.get('locations', poLine.locations)
    * def quantity = karate.get('quantity', poLine.cost.quantityPhysical)
    * def checkinItems = karate.get('checkinItems', poLine.checkinItems)

    * set poLine.id = id
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.cost.listUnitPrice = listUnitPrice
    * set poLine.cost.poLineEstimatedPrice = listUnitPrice
    * set poLine.isPackage = isPackage
    * set poLine.titleOrPackage = titleOrPackage
    * set poLine.paymentStatus = paymentStatus
    * set poLine.receiptStatus = receiptStatus
    * set poLine.cost.quantityPhysical = quantity
    * set poLine.locations = locations
    * set poLine.checkinItems = checkinItems

    Given path 'orders/order-lines'
    And request poLine
    When method POST
    Then status 201
