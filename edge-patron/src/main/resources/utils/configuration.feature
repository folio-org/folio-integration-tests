Feature: global finances

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': '*/*' }

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
