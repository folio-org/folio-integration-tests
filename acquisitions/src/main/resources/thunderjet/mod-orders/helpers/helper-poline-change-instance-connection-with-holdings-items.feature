@ignore
Feature: Helper for "poline-change-instance-connection-with-holdings-items"

  Background:
    * url baseUrl

  @CreateAndOpenOrderWithPEMixPoLine #(poLineId, orderId, title, checkinItems)
  Scenario: createAndOpenOrderWithPEMixPoLine
    * print 'CreatePEMixPoLine:: poLineId: ' + poLineId + ', orderId: ' + orderId + ', title: ' + title + ', checkinItems: ' + checkinItems

    # 1. Create an order
    * def v = call createOrder { id: '#(orderId)' }

    # 2. Create a POL
    * def poLine = read("classpath:samples/mod-orders/orderLines/minimal-mixed-order-line.json")
    * set poLine.id = poLineId
    * set poLine.purchaseOrderId = orderId
    * set poLine.titleOrPackage = title
    * set poLine.checkinItems = checkinItems
    * set poLine.isPackage = false
    * set poLine.cost.quantityPhysical = 1
    * set poLine.cost.quantityElectronic = 1
    * set poLine.physical.createInventory = "Instance, Holding, Item"
    * set poLine.eresource.createInventory = "Instance, Holding, Item"
    * set poLine.fundDistribution = []
    * set poLine.locations = [{ "locationId": #(globalLocationsId), "quantity": 1, "quantityPhysical": 1 }, { "locationId": #(globalLocationsId2), "quantity": 1, "quantityElectronic": 1 }]
    Given path "orders/order-lines"
    And request poLine
    When method POST
    Then status 201

    # 3. Open the order
    * def v = call openOrder { orderId: '#(orderId)' }