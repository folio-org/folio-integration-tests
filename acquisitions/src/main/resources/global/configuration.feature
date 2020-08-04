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
      "value": "10"
    }
    """
    When method POST
    Then status 201
