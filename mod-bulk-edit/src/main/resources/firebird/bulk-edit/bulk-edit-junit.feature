Feature: bulk-edit integration tests

  Background:
    * url baseUrl
    * callonce login admin

    * table modules
      | name                    |
      | 'mod-audit'             |
      | 'mod-orders'            |
      | 'mod-inventory-storage' |
      | 'mod-permissions'       |
      | 'mod-login'             |
      | 'mod-users'             |

    * table userPermissions
      | name        |
      | 'users.all' |
      | 'perms.all' |

    * table adminAdditionalPermissions
      | name |

    * table testedModules
      | name                     |
      | 'mod-data-export-spring' |
      | 'mod-data-export-worker' |

    * table testedModulesUserPermissions
      | name                     |
      | 'bulk-edit.all'          |
      | 'data-export.job.all'    |
      | 'data-export.config.all' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: enable tests modules mod-data-export-spring and mod-data-export-worker
    * print "get and install configured modules"
    Given call read('classpath:common/tenant.feature@install') { modules: '#(testedModules)', tenant: '#(testTenant)'}

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
#    * call login testAdmin
    * callonce read('classpath:global/mod_users_init_data.feature')