Feature: mod-login-saml integration tests

  Background:
    * callonce login admin
    * url baseUrl
    * table modules
      | name                                |
      | 'okapi'                             |
      | 'mod-permissions'                   |
      | 'mod-configuration'                 |
      | 'mod-login'                         |
      | 'mod-users'                         |
      # We can't add login-saml here. The reason is that mod-login-saml has mod-authtoken as a dependency
      # and once mod-authtoken is enabled (which it will be after registering mod-login-saml) we can no longer create
      # users without a token. common/setup-users.feature uses the supertenant to create the test user accounts without
      # using an x-okapi-token, so requiring a token breaks that.

    * table adminAdditionalPermissions
      | name                                |
      | 'users.all'                         |
      # We are not able to add the login-saml.* user permissions here. Instead we define our own table elsewhere and
      # and create those permissions in loginSaml.feature.

    * table userPermissions
      | name                                |
      # We are not able to add the login-saml.* user permissions here. Instead we define our own table elsewhere and
      # and create those permissions in loginSaml.feature.

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  # This is where to register mod-login-saml. See the NOTE above for why this is the way to do it.
  Scenario: get and install configured modules
    Given call read('classpath:common/tenant.feature@install') { modules: [{name: 'mod-login-saml'}], tenant: '#(testTenant)'}


