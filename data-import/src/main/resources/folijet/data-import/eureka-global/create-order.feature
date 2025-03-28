Feature: Create pending order
  # parameters: vendorId, poNumber

  Background:
    * url baseUrl

  Scenario: Create order
    Given path 'orders/composite-orders'
    And headers headersUser
    And request
    """
    {
      "vendor": "#(vendorId)",
      "orderType": "One-Time",
      "poNumber": "#(poNumber)",
      "workflowStatus": "Pending",
      "reEncumber": true,
    }
    """
    When method POST
    Then status 201