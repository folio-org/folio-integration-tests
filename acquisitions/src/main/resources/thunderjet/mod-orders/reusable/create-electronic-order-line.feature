@ignore
Feature: Create electronic order line
  # parameters: id, orderId, fundId, listUnitPrice, isPackage, paymentStatus, receiptStatus, locations
  # quantity, checkinItems, createInventory, fundDistribution

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create electronic order line
    * def poLine = read("classpath:samples/mod-orders/orderLines/minimal-order-electronic-line.json")

    * def id = karate.get("id", null)
    * def listUnitPrice = karate.get("listUnitPrice", poLine.cost.listUnitPriceElectronic)
    * def isPackage = karate.get("isPackage", poLine.isPackage)
    * def paymentStatus = karate.get("paymentStatus", poLine.paymentStatus)
    * def receiptStatus = karate.get("receiptStatus", poLine.receiptStatus)
    * def quantity = karate.get("quantity", poLine.cost.quantityElectronic)
    * def defaultLocations = poLine.locations
    * set defaultLocations[0].quantity = quantity
    * set defaultLocations[0].quantityElectronic = quantity
    * def locations = karate.get("locations", defaultLocations)
    * def checkinItems = karate.get("checkinItems", poLine.checkinItems)
    * def createInventory = karate.get("createInventory", poLine.eresource.createInventory)
    * def fundDistribution = karate.get("fundDistribution", poLine.fundDistribution)
    * def fundId = karate.get("fundId", fundDistribution.length > 0 ? fundDistribution[0].fundId : null)
    * def expenseClassId = karate.get("expenseClassId", fundDistribution.length > 0 ? fundDistribution[0].expenseClassId : null)

    * set poLine.id = id
    * set poLine.purchaseOrderId = orderId
    * if (fundId != null) poLine.fundDistribution[0].fundId = fundId
    * if (fundId != null) poLine.fundDistribution[0].code = fundId
    * if (expenseClassId != null) poLine.fundDistribution[0].expenseClassId = expenseClassId
    * set poLine.cost.listUnitPriceElectronic = listUnitPrice
    * set poLine.cost.poLineEstimatedPrice = listUnitPrice * quantity
    * set poLine.isPackage = isPackage
    * set poLine.paymentStatus = paymentStatus
    * set poLine.receiptStatus = receiptStatus
    * set poLine.cost.quantityElectronic = quantity
    * set poLine.locations = locations
    * set poLine.checkinItems = checkinItems
    * set poLine.eresource.createInventory = createInventory
    * set poLine.fundDistribution = fundDistribution

    Given path "orders/order-lines"
    And request poLine
    When method POST
    Then status 201
