Feature: Create order
  # parameters: id

  Background:
    * url baseUrl

  Scenario: createOrder
    Given path 'orders/composite-orders'
    And request
    """
    {
      id: '#(id)',
      vendor: '#(globalVendorId)',
      orderType: 'One-Time'
    }
    """
    When method POST
    Then status 201
