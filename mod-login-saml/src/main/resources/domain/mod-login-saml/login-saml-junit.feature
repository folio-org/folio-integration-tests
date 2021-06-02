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
      | name                                     |
# TODO Adding these here don't solve the missing permissions for setup-users.feature
#      | 'perms.permissions.get'            |
#      | 'perms.users.item.post'            |
#      | 'permissions.get'                  |
#      | 'users.item.post'                  |
      | 'configuration.entries.collection.get'   |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

