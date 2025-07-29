@ignore
Feature: Change order line instance connection
  # parameters: poLineId, instanceId, holdingsOperation, deleteAbandonedHoldings

  Background:
    * url baseUrl

  Scenario: changeOrderLineInstanceConnection
    Given path 'orders/order-lines', poLineId
    And request
    """
    {
      "operation": "Replace Instance Ref",
      "replaceInstanceRef": {
        "deleteAbandonedHoldings": "#(deleteAbandonedHoldings)",
        "holdingsOperation": "#(holdingsOperation)",
        "newInstanceId": "#(instanceId)"
      }
    }
    """
    When method PATCH
    Then status 204
