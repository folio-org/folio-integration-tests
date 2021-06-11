Feature: Login SAML

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-tenant': #(testTenant), 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Check endpoint missing okapi url header active is false
    Given path 'saml/check'
    When method GET
    Then status 200
    # A lot of the Rest Assured tests use the matchesJsonSchemaInClasspath method to validate JSON schema.
    # Karate has a different opinion about how to validate JSON schema. See https://github.com/intuit/karate#schema-validation
    # Here the only part of the schema returned is one property so about all we can check is the data type of that property
    # (this is karate's 'schema validation') and the value.
    Then match response ==
    """
    {
      active: '#boolean'
    }
    """
    Then match response.active == false

  # TODO In the rest assured tests this is 400 active true. But here it is active false 200. Which is correct?
  @Undefined
  Scenario: Check endpoint has okapi url header active is true
    * print 'undefined'
#    Given path 'saml/check'
#    And header x-okapi-url = 'http://localhost:9130'
#    When method GET
#    Then status 200
#    Then match response ==
#    """
#    {
#      active: '#boolean'
#    }
#    """
#    Then match response.active == true

  # In SamlAPITests.java a lot of what could be considered separate tests, are combined into a single method.
  # My feeling is that that isn't really the Karate-way, and am suggesting, when applicable (when the requests
  # and responses are depended on each other), that they be broken out into separate Karate scenarios.

  # Tests for /saml/login

  @Undefined
  Scenario: Login endpoint tests bad
    * print 'undefined'

  @Undefined
  Scenario: Login endpoint tests succeeds with 200 response
    * print 'undefined'

  @Undefined
  Scenario: Login with stripes url succeeds with 200 response
    * print 'undefined'

  @Undefined
  Scenario: Login with AJAX header and stripes fails with 401 response
    * print 'undefined'

  @Undefined
  Scenario: Login without correct headers fails with 500 response
    * print 'undefined'

  # Tests for CORS preflight for /saml/login

  @Undefined
  Scenario: CORS preflight options success and 204 response
    * print 'undefined'

  @Undefined
  Scenario: CORS preflight options failure no origin and 400 response
    * print 'undefined'

  @Undefined
  Scenario: CORS preflight options failure with invalid origin with empty value and 400 response
    * print 'undefined'

  @Undefined
  Scenario: CORS preflight options failure with invalid origin with wilddcard and and 400 response
    * print 'undefined'

  # Tests for /saml/callback

  @Undefined
  Scenario: CORS preflight options SAML callback success
    * print 'undefined'

  # Regenerate endpoint tests

  @Undefined
  Scenario: Get SAML regenerate endpoint with 200 response
    * print 'undefined'

  # This should combine the two requests, a PUT and and GET to verify that the change was made.
  @Undefined
  Scenario: Put SAML configuration with 200 response and ensure it has changed
    * print 'undefined'

  # Callback endpoint tests

  @Undefined
  Scenario: Setup POST SAML login need relay state and cookie with 200 response
    * print 'undefined'

  @Undefined
  Scenario: POST SAML callback success with 302 response
    * print 'undefined'

  @Undefined
  Scenario: POST SAML callback failure wrong cookie with 403 response
    * print 'undefined'

  @Undefined
  Scenario: POST SAML callback failure wrong relay with 403 response
    * print 'undefined'

  @Undefined
  Scenario: POST SAML callback failure no cookie with 403 response
    * print 'undefined'

  # GET/PUT configuration endpoint

  @Undefined
  Scenario: GET configuration endpoint with 200 response
    * print 'undefined'

  @Undefined
  Scenario: PUT configuration endpoint with 200 response
    * print 'undefined'

  # Misc tests

  @Undefined
  Scenario: Health endpoint test and 200 response
    * print 'undefined'

  @Undefined
  Scenario: Test GET configuration and 500 response
    * print 'undefined'

  @Undefined
  Scenario: Regenerate endpoint with no keystore and 500 response
    * print 'undefined'