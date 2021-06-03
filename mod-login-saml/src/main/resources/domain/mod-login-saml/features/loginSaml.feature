Feature: Login SAML

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

# Scenario: TODO
#    Given path ''
#    When method GET
#    Then status 200
