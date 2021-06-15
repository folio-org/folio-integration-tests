Feature: Opening hours

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Get all periods
    Given path 'calendar', 'periods'
    When method GET
    Then status 200

  Scenario:
    Given path 'calendar', 'periods'
    When method GET
    Then status 200