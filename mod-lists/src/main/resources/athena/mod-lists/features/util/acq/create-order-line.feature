Feature: Create electronic purchase order line in storage
  # parameters: id, orderId, poLineNumber, title, fundDistribution
  # The acquisition method is not validated by storage, so a random id is used, like the mod-fqm-manager sample data
  Background:
    * url baseUrl

  Scenario: Create electronic purchase order line
    * def acquisitionMethod = call uuid
    * def poLine =
      """
      {
        id: '#(id)',
        purchaseOrderId: '#(orderId)',
        poLineNumber: '#(poLineNumber)',
        titleOrPackage: '#(title)',
        orderFormat: 'Electronic Resource',
        source: 'User',
        acquisitionMethod: '#(acquisitionMethod)',
        paymentStatus: 'Awaiting Payment',
        receiptStatus: 'Receipt Not Required',
        cost: { listUnitPriceElectronic: 10, quantityElectronic: 1, currency: 'USD', poLineEstimatedPrice: 10 },
        eresource: { createInventory: 'None' },
        fundDistribution: '#(fundDistribution)'
      }
      """
    Given path 'orders-storage/po-lines'
    And request poLine
    When method POST
    Then status 201
