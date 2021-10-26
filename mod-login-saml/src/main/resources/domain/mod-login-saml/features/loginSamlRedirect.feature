Feature: Login SAML with a REDIRECT binding

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
    * configure lowerCaseResponseHeaders = true

  Scenario: Do preflight request, POST to saml login endpoint, and receive correct response for REDIRECT binding
    Given path "_/invoke/tenant/" + testTenant + "/saml/login"
    And header Origin = baseUrl
    And header Access-Control-Request-Method = "POST"
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "POST"
    And match header access-control-allow-origin == baseUrl

    Given path "saml/login"
    And header content-type = "application/json"
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
      "location": "#string"
    }
    """
    And match responseCookies contains { "relayState": "#notnull" }
    And match header content-type == "application/json"
