Feature: Login SAML with a POST binding

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers =
    """
    {
      "X-Okapi-Tenant": "#(testTenant)",
      "X-Okapi-Token": "#(okapitoken)",
      "Accept": "application/json, text/plain"
    }
    """

  Scenario: Do preflight request, POST to saml login endpoint, and receive correct response for POST binding
    Given path "saml/login"
    And header Origin = baseUrl
    And header Access-Control-Request-Method = "POST"
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "POST"
    And match header access-control-allow-origin == "*"

    Given path "saml/login"
    And header Content-Type = "application/json"
    * def stripesUrl = baseUrl + "/some/route"
    And request
    """
    {
      "stripesUrl": "#(stripesUrl)"
    }
    """
    When method POST
    Then status 200
    And match response ==
    """
    {
      "bindingMethod": "#(method)",
      "location": "#string",
      "relayState": "#string",
      "samlRequest": "#string"
    }
    """
    And match responseCookies contains { "relayState": "#notnull" }
    And match header Content-Type == "application/json"



