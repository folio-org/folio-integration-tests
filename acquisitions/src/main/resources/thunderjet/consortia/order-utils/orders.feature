Feature: global orders

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

    * callonce variables


  Scenario: create acquisition methods
    Given path 'orders/acquisition-methods'
    And request
    """
    {
      "id": "#(globalApprovalPlanAcqMethodId)",
      "value": "Approval Plan Method for Karate tests",
      "source": "System"
    }
    """
    When method POST
    Then status 201

    Given path 'orders/acquisition-methods'
    And request
    """
    {
      "id": "#(globalPurchaseAcqMethodId)",
      "value": "Purchase Method for Karate tests",
      "source": "System"
    }
    """
    When method POST
    Then status 201

