Feature: global finances

  Background:
    * url baseUrl
    * callonce login testAdmin

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)'  }

  Scenario: Create orders-storage setting to increase the POL limit
    Given path 'orders-storage/settings'
    And request { "key": "poLines-limit", "value": "999" }
    When method POST
    Then status 201
