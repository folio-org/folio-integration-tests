# Tests of unauthenticated routes (no okapi token) don't require the background variables so we add it to a different
# feature here.
Feature: Login SAML Unauthenticated

  Background:
    * url baseUrl
    * configure headers = { 'x-okapi-tenant': #(testTenant) }

  @Undefined
  Scenario: Check endpoint bad request
  * print 'undefined'
# TODO In the rest assured tests, this is 400, not 200 active false. I believe this is because when the tests
# are run against vertx directly the request without the headers responds 400 (bad request) -- never reaching
# getSamlCheck. But when it is run through okapi the request is routed to the getSamlCheck method.
#  Given path 'saml/check'
#  When method GET
#  Then status 400