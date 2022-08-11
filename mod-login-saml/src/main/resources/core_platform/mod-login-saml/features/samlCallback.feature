# NOTE The saml/callback endpoint is called by the IdP after authentication is performed.
# Because the saml/callback endpoint requires a signature from the IdP, doing a true integration test of it will
# be difficult if not impossible.
Feature: Test what we can for the callback endpoint

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers =
    """
    {
      "X-Okapi-Tenant": "#(testTenant)",
      "X-Okapi-Token": "#(okapitoken)"
    }
    """
    * configure lowerCaseResponseHeaders = true

  Scenario: Test CORS for the callback endpoint
    Given path "_/invoke/tenant/" + testTenant + "/saml/callback"
    And header Origin = baseUrl
    And header Access-Control-Request-Method = "POST"
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods == "POST"
    And match header access-control-allow-origin == baseUrl
    And match header access-control-allow-credentials == "true"
    And match responseHeaders contains { 'access-control-allow-headers': '#notpresent' }

  Scenario: Test CORS request to wrong endpoint triggers default CORS handling in Okapi
    Given path "/saml/callback"
    And header Origin = baseUrl
    And header Access-Control-Request-Method = "POST"
    When method OPTIONS
    Then status 204
    And match header access-control-allow-headers contains "X-Okapi-Token"
