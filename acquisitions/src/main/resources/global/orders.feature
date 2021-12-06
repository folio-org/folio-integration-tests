Feature: global orders

  Background:
    * url baseUrl
    * call login testAdmin

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }

    * callonce variables


  Scenario: create acquisition methods
    Given path 'orders/acquisition-methods'
    And request
    """
    {
      "id": "#(globalApprovalPlanAcqMethodId)",
      "value": "Approval Plan",
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
      "value": "Purchase",
      "source": "System"
    }
    """
    When method POST
    Then status 201

