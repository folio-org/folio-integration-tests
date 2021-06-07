Feature: Login SAML

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: SAML Check
     Given path 'saml/check'
     And header x-okapi-tenant = testTenant
     And header x-okapi-token = '#(okapitoken)'
     When method GET
     Then status 200
