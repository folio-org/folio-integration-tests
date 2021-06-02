Feature: Saml login

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Check endpoint tests
    Given path 'saml/check'
    When method GET
    Then status 200