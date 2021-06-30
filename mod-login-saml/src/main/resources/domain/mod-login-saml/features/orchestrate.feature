Feature: Orchestrate the SAML tests

  Scenario: Set the right permissions for the admin user to allow for SAML configuration
    Given call read("configurePermissions.feature")

  Scenario: Check endpoint returns active is false when IdP is not yet configured
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
    Given path "saml/check"
    When method GET
    Then status 200
    And match response == { active: false }

  Scenario: Configure and test POST SAML binding
    * def postBindingIdP =
    """
    {
      "idpUrl": "https://idp.ssocircle.com",
      "binding": "POST",
      "method": "POST",
      "samlAttribute": "UserId",
      "userProp": "externalSystemId"
    }
    """
    * call read("configureSaml.feature") postBindingIdP
    * call read("loginSamlPost.feature") postBindingIdP

  Scenario: Configure and test REDIRECT SAML binding
    * def redirectBindingIdP =
    """
    {
      "idpUrl": "https://samltest.id/saml/idp",
      "binding": "REDIRECT",
      "method": "GET",
      "samlAttribute": "uid",
      "userProp": "username"
    }
    """
    * call read("configureSaml.feature") redirectBindingIdP
    * call read("loginSamlRedirect.feature") redirectBindingIdP

   Scenario: Test some failure scenarios
     * call read("samlFailures.feature")

  Scenario: Test callback scenarios
    * call read("samlCallback.feature")