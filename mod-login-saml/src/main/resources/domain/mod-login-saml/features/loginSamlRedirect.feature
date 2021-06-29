Feature: Login SAML with a REDIRECT binding

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'x-okapi-tenant': #(testTenant), 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: POST to saml login endpoint and receive correct response
    Given path 'saml/login'
    And header Content-Type = "application/json"
    And request
    """
    {
      "stripesUrl": "http://localhost:3000/test/path"
    }
    """
    When method POST
    Then status 200
    And match response ==
    """
    {
      bindingMethod: #(method),
      location: #string
    }
    """
    And match responseCookies contains { relayState: "#notnull" }

#  @Undefined
#  Scenario: Login with AJAX header and stripes fails with 401 response
#    * print 'undefined'
#
#  @Undefined
#  Scenario: Login without correct headers fails with 500 response
#    * print 'undefined'



