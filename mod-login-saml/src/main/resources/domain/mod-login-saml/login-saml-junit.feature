Feature: mod-login-saml integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-login-saml'                    |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                |
      | 'configuration.entries.collection.get'          |
      | 'templates.collection.get'          |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
