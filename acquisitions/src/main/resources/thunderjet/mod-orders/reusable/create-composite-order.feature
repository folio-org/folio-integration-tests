@ignore
Feature: Create composite order
  # parameters: orderId, globalVendorId

  Background: createCompositeOrder
    * url baseUrl

  Scenario: Create composite order
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(orderId)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201
