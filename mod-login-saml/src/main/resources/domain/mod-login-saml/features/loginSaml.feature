Feature: Login SAML

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-tenant': #(testTenant), 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

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



