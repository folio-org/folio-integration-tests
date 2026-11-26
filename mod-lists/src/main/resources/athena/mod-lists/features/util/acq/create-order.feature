Feature: Create ongoing open purchase order in storage
  # parameters: id, poNumber, vendorId
  # Posted to storage so the order is "Open" without encumbrances, like the mod-fqm-manager sample data
  Background:
    * url baseUrl

  Scenario: Create ongoing open purchase order
    Given path 'orders-storage/purchase-orders'
    And request { id: '#(id)', poNumber: '#(poNumber)', vendor: '#(vendorId)', orderType: 'Ongoing', ongoing: { interval: 123, isSubscription: false }, workflowStatus: 'Open' }
    When method POST
    Then status 201
