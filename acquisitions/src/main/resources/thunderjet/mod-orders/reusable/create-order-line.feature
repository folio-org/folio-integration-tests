@ignore
Feature: Create order line
  # parameters: id, orderId, fundId, listUnitPrice, listUnitPriceElectronic, isPackage, titleOrPackage, paymentStatus, receiptStatus, locations, orderFormat
  # quantity, quantityElectronic, checkinItems, createInventory, fundDistribution, claimingActive, claimingInterval, suppressInstanceFromDiscovery, productIds

  Background:
    * url baseUrl

  Scenario: createOrderLine
    * def poLine = read("classpath:samples/mod-orders/orderLines/minimal-order-line.json")

    * def id = karate.get("id", null)
    * def listUnitPrice = karate.get("listUnitPrice", 1.0)
    * def listUnitPriceElectronic = karate.get("listUnitPriceElectronic", null)
    * def isPackage = karate.get("isPackage", false)
    * def titleOrPackage = karate.get("titleOrPackage", "test")
    * def paymentStatus = karate.get("paymentStatus", null)
    * def receiptStatus = karate.get("receiptStatus", null)
    * def orderFormat = karate.get("orderFormat", poLine.orderFormat)
    * def locations = karate.get("locations", poLine.locations)
    * def quantity = karate.get("quantity", poLine.cost.quantityPhysical)
    * def quantityElectronic = karate.get("quantityElectronic", 0)
    * def checkinItems = karate.get("checkinItems", poLine.checkinItems)
    * def createInventory = karate.get("createInventory", poLine.physical.createInventory)
    * def fundDistribution = karate.get("fundDistribution", poLine.fundDistribution)
    * def fundId = karate.get("fundId", fundDistribution[0].fundId)
    * def expenseClassId = karate.get("expenseClassId", fundDistribution[0].expenseClassId)
    * def claimingActive = karate.get("claimingActive", poLine.claimingActive)
    * def claimingInterval = karate.get("claimingInterval", poLine.claimingInterval)
    * def suppressInstanceFromDiscovery = karate.get("suppressInstanceFromDiscovery", null)
    * def productIds = karate.get("productIds", poLine.details.productIds)

    * set poLine.id = id
    * set poLine.purchaseOrderId = orderId
    * set poLine.fundDistribution[0].fundId = fundId
    * set poLine.fundDistribution[0].code = fundId
    * set poLine.fundDistribution[0].expenseClassId = expenseClassId
    * set poLine.cost.listUnitPrice = listUnitPrice
    * set poLine.cost.listUnitPriceElectronic = listUnitPriceElectronic
    * set poLine.cost.poLineEstimatedPrice = listUnitPrice
    * set poLine.isPackage = isPackage
    * set poLine.titleOrPackage = titleOrPackage
    * set poLine.paymentStatus = paymentStatus
    * set poLine.receiptStatus = receiptStatus
    * set poLine.cost.quantityPhysical = quantity
    * set poLine.cost.quantityElectronic = quantityElectronic
    * set poLine.orderFormat = orderFormat
    * set poLine.locations = locations
    * set poLine.checkinItems = checkinItems
    * set poLine.physical.createInventory = createInventory
    * set poLine.fundDistribution = fundDistribution
    * set poLine.claimingActive = claimingActive
    * set poLine.claimingInterval = claimingInterval
    * set poLine.suppressInstanceFromDiscovery = suppressInstanceFromDiscovery
    * set poLine.details.productIds = productIds

    Given path "orders/order-lines"
    And request poLine
    When method POST
    Then status 201
