Feature: Global orders

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': '*/*' }
    * callonce variablesCentral


  Scenario: create acquisition methods
    Given path 'orders/acquisition-methods'
    And request
    """
    {
      "id": "#(centralApprovalPlanAcqMethodId)",
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
      "id": "#(centralPurchaseAcqMethodId)",
      "value": "Purchase Method for Karate tests",
      "source": "System"
    }
    """
    When method POST
    Then status 201

