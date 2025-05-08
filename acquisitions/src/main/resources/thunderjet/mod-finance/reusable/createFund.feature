Feature: fund

  Background:
    * url baseUrl

  Scenario: createFund

    * def code = karate.get('code', id)
    * def ledgerId = karate.get('ledgerId', globalLedgerId)
    * def externalAccountNo = karate.get('externalAccountNo', '1111111111111111111111111')
    * def fundStatus = karate.get('fundStatus', 'Active')
    * def acqUnitIds = karate.get('acqUnitIds', [])
    * def name = karate.get('name', "")

    Given path 'finance/funds'
    And request
    """
    {
      "fund": {
        "id": "#(id)",
        "code": "#(code)",
        "description": "",
        "externalAccountNo": "#(externalAccountNo)",
        "fundStatus": "#(fundStatus)",
        "ledgerId": "#(ledgerId)",
        "name": "#(name)",
        "acqUnitIds": "#(acqUnitIds)",
      }
    }
    """
    When method POST
    Then status 201
