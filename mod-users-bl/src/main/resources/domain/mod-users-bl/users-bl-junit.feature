Feature: mod-login integration tests

  Background:
    * callonce login admin
    * url baseUrl
    * table modules
      | name                                |
      | 'okapi'                             |
      | 'mod-permissions'                   |
      | 'mod-configuration'                 |
      | 'mod-users'                         |
      | 'mod-login'                         |
      | 'mod-users-bl'                      |
      # See note below about when mod-users-bl needs to be enabled. You can't do it here.

    * table adminAdditionalPermissions
      | name                                |
      | 'users.all'                         |
      | 'users.item.post'                   |
      | 'login.item.post'                   |
      | 'perms.permissions.get'             |
      | 'perms.users.item.post'             |
      | 'users.item.post'                   |
      | 'perms.permissions.get'             |

    * table userPermissions
      | name                                |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  # It would seem that mod-users-bl cannot be enabled before mod-authtoken, otherwise permissions problems will happen.
  # mod-authtoken is enabled as the last step of setup-users.feature.

#  Scenario: install mod-users-bl
#    Given call read('classpath:common/tenant.feature@install') { modules: [{name: 'mod-users-bl'}], tenant: '#(testTenant)'}



