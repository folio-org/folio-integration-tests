Feature: fund

  Background:
    * url baseUrl

  Scenario: createFund

    * def ledgerId = karate.get('ledgerId', globalLedgerId)
    * def fundStatus = karate.get('fundStatus', 'Active')

    Given path 'finance-storage/funds'
    And request
    """
    {
      "id": "#(id)",
      "code": "#(code)",
      "description": "",
      "externalAccountNo": "#(externalAccountNo)",
      "fundStatus": "Active",
      "ledgerId": "#(ledgerId)",
      "name": ""
    }
    """
    When method POST
    Then status 201
