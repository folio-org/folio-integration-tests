Feature: Configure SAML

  Background:
    * url baseUrl
    * call login testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-tenant': #(testTenant), 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Validate IdP url
    Given path 'saml/validate'
    And param type = 'idpurl'
    And param value = idpUrl
    When method GET
    Then status 200

  Scenario: Configure an IdP
    # Configure the IdP using the same credentials we've been using so far. This admin user should have the permissions
    # based on what we have done in previous steps.
    Given path 'saml/configuration'
    # Disable the mod-authtoken's cache. Without this we would need to sleep for > 60 seconds for mod-authtoken
    # to be aware of the new permissions.
    And header Authtoken-Refresh-Cache = "true"
    # Here we need the idpUrl to actually be reachable and return XML.
    And request
    """
    {
      idpUrl: #(idpUrl),
      samlBinding: "#(binding)",
      samlAttribute: "#(samlAttribute)",
      userProperty: "#(userProp)",
      okapiUrl: "http://localhost:9130"
    }
    """
    When method PUT
    Then status 200
    And match response ==
    """
    {
      idpUrl: #(idpUrl),
      samlBinding: "#(binding)",
      samlAttribute: "#(samlAttribute)",
      userProperty: "#(userProp)",
      okapiUrl: "http://localhost:9130",
      metadataInvalidated: true
    }
    """

  Scenario: Check endpoint returns active is true when IdP is configured
    Given path 'saml/check'
    When method GET
    Then status 200
    And match response == { active: true }

  Scenario: Get the SAML IdP metadata for the tenant and check the XML response
    Given path 'saml/regenerate'
    When method GET
    Then status 200
    And match response == { fileContent: #string }



