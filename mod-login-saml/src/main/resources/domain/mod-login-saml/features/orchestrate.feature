# A way to run the tests in a certain order.
Feature: Orchestrate the SAML tests
  Scenario: Run tests in the the right order
    # We first run saml configuration, which the test admin user takes care of.
    * call read('configureSaml.feature')
    # Then we do an actual saml login which the non-admin user does.
    * call read('loginSaml.feature')