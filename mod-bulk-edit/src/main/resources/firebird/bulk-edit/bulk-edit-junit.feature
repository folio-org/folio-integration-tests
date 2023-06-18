@Ignore
Feature: bulk-edit integration tests

  Background:
    * url baseUrl
    * callonce login admin
    * configure readTimeout = 600000

    * table modules
      | name                     |
      | 'mod-login'              |
      | 'mod-permissions'        |
      | 'mod-configuration'      |
      | 'mod-circulation'        |
      | 'mod-audit'              |
      | 'mod-orders'             |
      | 'mod-inventory-storage'  |
      | 'mod-inventory'          |
      | 'mod-users'              |
      | 'mod-data-export-worker' |

    * table userPermissions
      | name        |
      | 'users.all' |
      | 'perms.all' |
      | 'inventory-storage.all'  |
      | 'inventory.all'          |

    * table testedModules
      | name                     |
      | 'mod-data-export-spring' |

    * table testedModulesUserPermissions
      | name                        |
      | 'bulk-edit.all'             |
      | 'data-export.job.all'       |
      | 'data-export.config.all'    |
      | 'data-export.job.item.post' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: enable tests modules mod-data-export-spring
    * print "get and install configured modules"
    Given call read('classpath:common/tenant.feature@install') { modules: '#(testedModules)', tenant: '#(testTenant)'}
    * pause(350000)

  Scenario: update user permissions with tested modules permissions
    * callonce login testAdmin
    Given path 'perms/users'
    And header x-okapi-tenant = testTenant
    And header x-okapi-token = okapitoken
    And param query = 'userId=00000000-1111-5555-9999-999999999992'
    When method GET
    Then status 200
    And def permissionEntry = $.permissionUsers[0]

    * def newPermissions = $testedModulesUserPermissions[*].name
    * def updatedPermissions = karate.append(permissionEntry.permissions, newPermissions)
    * karate.set('permissionEntry', '$.permissions', updatedPermissions)

    * print "update user permissions with tested modules permissions"
    Given path 'perms/users', permissionEntry.id
    And header x-okapi-tenant = testTenant
    And header x-okapi-token = okapitoken
    And request permissionEntry
    When method PUT
    Then status 200

  Scenario: init test data
    * callonce read('classpath:global/mod_users_init_data.feature')
    * callonce read('classpath:global/mod_item_init_data.feature')