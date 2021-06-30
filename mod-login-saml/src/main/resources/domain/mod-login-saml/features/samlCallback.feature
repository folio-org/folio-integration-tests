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

  Scenario: Test CORS for the callback endpoint
    Given path "saml/callback"
    And header Origin = baseUrl
    And header Access-Control-Request-Method = "POST"
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "POST"
    And match header access-control-allow-origin == "*"
    # The rest assured test checks here for Access-Control-Allow-Credentials = true. But this isn't returned
    # in the response in the karate tests. Not sure why this is.
