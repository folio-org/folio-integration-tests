Feature: KB Credentials

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Get all KB Credentials
    Given path '/eholdings/kb-credentials'
    When method GET
    Then status 200