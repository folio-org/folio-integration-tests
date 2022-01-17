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
      | 'mod-feesfines'                     |
      | 'mod-inventory'                     |
      # We can't add mod-users-bl here. The reason is that mod-users-bl has mod-authtoken as a dependency
      # See note below about when mod-users-bl needs to be enabled. You can't do it here.

    * table adminAdditionalPermissions
      | name                                |
      | 'users.all'                         |
      | 'perms.users.get'                   |
      | 'perms.users.item.put'              |
      | 'perms.users.assign.immutable'      |
      | 'owners.item.post'                  |
      | 'accounts.item.post'                |
      # We are not able to add the mod-users-bl user permissions here. Instead we define our own table in configurePermissions.feature file
      # and create those permissions there.

    * table userPermissions
      | name                                |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  # It would seem that mod-users-bl cannot be enabled before mod-authtoken, otherwise permissions problems will happen.
  # mod-authtoken is enabled as the last step of setup-users.feature.
  Scenario: install mod-users-bl
    Given call read('classpath:common/tenant.feature@install') { modules: [{name: 'mod-users-bl'}], tenant: '#(testTenant)'}



