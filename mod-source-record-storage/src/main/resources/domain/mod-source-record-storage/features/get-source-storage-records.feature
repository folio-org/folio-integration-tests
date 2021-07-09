Feature: Source-Record-Storage

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Get storage records
    Given path 'source-storage', 'records'
    When method GET
    Then status 200