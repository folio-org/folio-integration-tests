Feature: Create fund with params

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create fund with params

    * def ledgerId = karate.get('ledgerId', globalLedgerId)
    * def fundStatus = karate.get('fundStatus', 'Active')

    Given path 'finance/funds'
    And request
    """
    {
      "fund": {
        "id": "#(id)",
        "code": "#(code)",
        "description": "",
        "externalAccountNo": "#(externalAccountNo)",
        "fundStatus": "Active",
        "ledgerId": "#(ledgerId)",
        "name": "",
      }
    }
    """
    When method POST
    Then status 201
