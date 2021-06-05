Feature: Login SAML


  Background:
    * url baseUrl

# This doesn't work because testUser hasn't been created yet. Creating users when mod-login-saml is in scope
# doesn't currently work as shown in this commit: https://github.com/folio-org/folio-integration-tests/commit/bc03be5b7c99ab477eff0fed23643a2a304db2b8
#    * callonce login testUser
#    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  # NOTE A lot of the current tests in mod-login-saml (in SamlAPITest.java) use the TOKEN_HEADER variable. Yet this
  # variable has a hardcoded value of 'saml-test'. A variable like this won't make it through okapi's token validation.
  # If we're going to require x-okapi-token for integration tests, it would seem we're going to need a logged in
  # user with a valid token.
  Scenario: SAML Check
     Given path 'saml/check'
     And header x-okapi-tenant = testTenant
     # This doesn't work. See note above.
     #And header x-okapi-token = '#(okapitoken)'
     When method GET
     Then status 200
