Feature: Login SAML

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-tenant': #(testTenant), 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Check endpoint missing okapi url header active is false
    Given path 'saml/check'
    When method GET
    Then status 200
    # NOTE Karate has a different opinion about how to validate JSON schema. See https://github.com/intuit/karate#schema-validation
    # Here the only part of the schema returned is one property so about all we can check is the data type of that
    # property and the value.
    Then match response ==
    """
    {
      active: '#boolean'
    }
    """
    Then match response.active == false

  # TODO In the rest assured tests this is 400 active true. But here it is active false 200. Which is correct?
  Scenario: Check endpoint has okapi url header active is true
    Given path 'saml/check'
    # TODO It is unclear what this should be to work. Does okapi validate this against something?
    And header x-okapi-url = 'http://localhost:9130'
    When method GET
    Then status 200
    Then match response ==
    """
    {
      active: '#boolean'
    }
    """
    Then match response.active == true

  @Undefined
  Scenario:
    * print 'undefined'

  @Undefined
  Scenario:
    * print 'undefined'

  @Undefined
  Scenario:
    * print 'undefined'

  @Undefined
  Scenario:
    * print 'undefined'

  @Undefined
  Scenario:
    * print 'undefined'

  @Undefined
  Scenario:
    * print 'undefined'

  @Undefined
  Scenario:
    * print 'undefined'

  @Undefined
  Scenario:
    * print 'undefined'

  @Undefined
  Scenario:
    * print 'undefined'

  @Undefined
  Scenario:
    * print 'undefined'

  @Undefined
  Scenario:
    * print 'undefined'

  @Undefined
  Scenario:
    * print 'undefined'

