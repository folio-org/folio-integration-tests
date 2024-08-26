Feature: fund

  Background:
    * url baseUrl

  Scenario: createFund

    * def code = karate.get('code', id)
    * def ledgerId = karate.get('ledgerId', '5e4fbdab-f1b1-4be8-9c33-d3c41ec9a695')
    * def externalAccountNo = karate.get('externalAccountNo', '1111111111111111111111111')
    * def fundStatus = karate.get('fundStatus', 'Active')

    Given path 'finance-storage/funds'
    And request
    """
    {
      "id": "#(id)",
      "code": "#(code)",
      "description": "",
      "externalAccountNo": "#(externalAccountNo)",
      "fundStatus": "#(fundStatus)",
      "ledgerId": "#(ledgerId)",
      "name": ""
    }
    """
    When method POST
    Then status 201