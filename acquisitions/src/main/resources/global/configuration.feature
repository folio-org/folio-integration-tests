Feature: global finances

  Background:
    * url baseUrl
    * call login testAdmin

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)' }

  Scenario: update configuration poline limit
    Given path 'configurations/entries'
    And request
    """
    {
      "module": "ORDERS",
      "configName": "poLines-limit",
      "enabled": true,
      "value": "999"
    }
    """
    When method POST
    Then status 201


  Scenario: Create configuration with UTC timezone
    Given path 'configurations/entries'
    And request
    """
    {
      "id": "2574216d-d541-4de9-9db7-42bb6891de2e",
      "module": "ORG",
      "configName": "localeSettings",
      "enabled": true,
      "value": "{\"locale\":\"en-US\",\"timezone\":\"UTC\",\"currency\":\"USD\"}"
    }
    """
    When method POST
    Then status 201
