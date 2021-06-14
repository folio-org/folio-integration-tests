Feature: Login SAML

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-tenant': #(testTenant), 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Check endpoint returns active is false when IdP is not configured
    Given path 'saml/check'
    When method GET
    Then status 200
    # A lot of the Rest Assured tests use the matchesJsonSchemaInClasspath method to validate JSON schema.
    # Karate has a different opinion about how to validate JSON schema. See https://github.com/intuit/karate#schema-validation
    # Here the only part of the schema returned is one property so all we can check is the data type of that property
    # (this is karate's 'schema validation') and the value.
    Then match response ==
    """
    {
      active: '#boolean'
    }
    """
    Then match response.active == false

  # TODO We will need to configure IdP for the karate tests for this to work.
  @Undefined
  Scenario: Check endpoint returns active is true when IdP is configured
    * print 'undefined'

  # In SamlAPITests.java a lot of what could be considered separate tests are combined into a single method.
  # What I'm doing here is breaking what is currently a single method test (in SamlAPITests.java) out into a
  # few separate scenarios.

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



