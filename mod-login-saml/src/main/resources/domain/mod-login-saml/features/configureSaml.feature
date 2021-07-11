Feature: Configure SAML

  Background:
    * url baseUrl
    * call login testAdmin
    * configure headers =
    """
    {
      "X-Okapi-Tenant": "#(testTenant)",
      "X-Okapi-Token": "#(okapitoken)",
      "Accept": "application/json, text/plain"
    }
    """
    * configure lowerCaseResponseHeaders = true

  Scenario: Do preflight and configure an IdP
    Given path "saml/configuration"
    And header Origin = baseUrl
    And header Access-Control-Request-Method = "PUT"
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "PUT"

    # Configure the IdP using the same credentials we've been using so far. This admin user should have the permissions
    # based on what we have done in previous steps.
    Given path "saml/configuration"
    # Disable the mod-authtoken"s cache. Without this we would need to sleep for > 60 seconds for mod-authtoken
    # to be aware of the new permissions.
    And header Authtoken-Refresh-Cache = "true"
    # Here we need the idpUrl to actually be reachable and return XML.
    And header Content-Type = "application/json"
    And request
    """
    {
      "idpUrl": "#(idpUrl)",
      "samlBinding": "#(binding)",
      "samlAttribute": "#(samlAttribute)",
      "userProperty": "#(userProp)",
      "okapiUrl": "#(baseUrl)"
    }
    """
    When method PUT
    Then status 200
    And match response ==
    """
    {
      "idpUrl": "#(idpUrl)",
      "samlBinding": "#(binding)",
      "samlAttribute": "#(samlAttribute)",
      "userProperty": "#(userProp)",
      "okapiUrl": "#(baseUrl)",
      "metadataInvalidated": true
    }
    """

  Scenario: Do preflight and check endpoint returns active is true when IdP is configured
    Given path "saml/check"
    And header Origin = baseUrl
    And header Access-Control-Request-Method = "GET"
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "GET"

    Given path "saml/check"
    When method GET
    Then status 200
    And match response == { active: true }

  Scenario: Do preflight and get the SAML IdP metadata for the tenant and check the response
    Given path "saml/regenerate"
    And header Origin = baseUrl
    And header Access-Control-Request-Method = "GET"
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "GET"

    Given path "saml/regenerate"
    When method GET
    Then status 200
    And match response == { "fileContent": "#string" }
    # NOTE a lot more validation could be done here of the XML but we would end up calling the same java
    # methods that the rest assured tests do inside of karate. Karate itself doesn't have schema validation
    # of xml.



