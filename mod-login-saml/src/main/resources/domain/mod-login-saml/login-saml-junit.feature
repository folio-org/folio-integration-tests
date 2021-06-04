Feature: mod-login-saml integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-configuration'                 |
# Comment this in and setup-users.feature will fail.
# Without this the mod-login-saml module won't be registered and routes will 404.
      | 'mod-login-saml'                    |

# Adding permissions here don't help.
    * table adminAdditionalPermissions
      | name                                |
#      | 'perms.all'                         |
#      | 'login.all'                         |
#      | 'users.all'                         |
#      | 'configuration.all'                 |
#      | 'login-saml.all'                    |
#      | 'perms.permissions.get'             |
#      | 'perms.users.item.post'             |
#      | 'users.item.post'                   |

# Adding permissions here don't help either.
    * table userPermissions
      | name                                |
#      | 'perms.permissions.get'             |
#      | 'perms.users.item.post'             |
#      | 'users.item.post'                   |
# Same here.
    * table desiredPermissions
      | name                  |
#      | 'users.item.post'     |
#      | 'perms.users.item.post'     |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
