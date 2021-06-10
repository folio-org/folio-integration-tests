Feature: mod-login-saml integration tests

  Background:
    * callonce login admin
    * url baseUrl

    # NOTE Do not define mod-login-saml here. If you do, setup-users.feature will fail because mod-login-saml
    # will require the requests to setup a test user to have a valid token for the auto generated tenant, which will
    # not be available yet since the test users haven't been created. The solution is to delay registering
    # mod-login-saml until after the test user has been created. Then the test user can be logged in in
    # loginSaml.feature to get a valid token.
    * table modules
      | name                                |
      | 'mod-permissions'                   |
      | 'mod-login'                         |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  # This is where to register mod-login-saml. See the NOTE above for why this is the way to do it.
  Scenario: get and install configured modules
    Given call read('classpath:common/tenant.feature@install') { modules: [{name: 'mod-login-saml'}], tenant: '#(testTenant)'}
