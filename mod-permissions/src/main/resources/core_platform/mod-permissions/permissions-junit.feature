Feature: mod-permissions integration tests

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

    * table adminAdditionalPermissions
      | name                                |
      | 'users.all'                         |
      # We are not able to add the login-saml.* user permissions here. Instead we define our own table elsewhere and
      # and create those permissions in loginSaml.feature.

    * table userPermissions
      | name                                |
  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

