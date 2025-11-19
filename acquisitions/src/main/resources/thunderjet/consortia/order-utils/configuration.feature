Feature: global finances

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Authtoken-Refresh-Cache': 'true', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenantName)', 'Accept': '*/*' }

  Scenario: Create orders-storage setting to increase the POL limit
    Given path 'orders-storage/settings'
    And request { "key": "poLines-limit", "value": "999" }
    When method POST
    Then status 201