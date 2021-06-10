# Tests of unauthenticated routes (no okapi token) don't require the background variables so we add it to a different
# feature.
Feature: Login SAML Unauthenticated

  Background:
    * url baseUrl
    * configure headers = { 'x-okapi-tenant': #(testTenant) }

  Scenario: Check endpoint bad request
  Given path 'saml/check'
  When method GET
  # TODO In the rest assured tests, this is 400, not 200 active false.
  Then status 400