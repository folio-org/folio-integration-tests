Feature: fund

  Background:
    * url baseUrl

  Scenario: createRestrictedFund

    * def code = karate.get('code', id)
    * def ledgerId = karate.get('ledgerId', globalLedgerId)
    * def externalAccountNo = karate.get('externalAccountNo', '1111111111111111111111111')
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
        "fundStatus": "#(fundStatus)",
        "ledgerId": "#(ledgerId)",
        "restrictByLocations": true,
        "locations": [
          {
            "locationId": "#(globalLocationsId)"
          }
        ],
        "name": "",
      }
    }
    """
    When method POST
    Then status 201
