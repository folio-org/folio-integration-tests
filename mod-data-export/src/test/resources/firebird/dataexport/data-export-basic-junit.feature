Feature: mod-orders integration tests

  Background:
    * url baseUrl
    * callonce login admin
    * configure readTimeout = 600000

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-data-export'           |
      | 'mod-login'                 |
      | 'mod-configuration'         |
      | 'mod-source-record-storage' |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-entities-links'        |

    * table userPermissions
      | name                    |
      | 'data-export.all'       |
      | 'configuration.all'     |
      | 'inventory-storage.all' |
      | 'source-storage.all'    |
      | 'inventory.instances.collection.get' |
      | 'instance-authority-links.authority-statistics.collection.get' |

    * table exportModules
      | name                     |
      | 'mod-data-export-spring' |
      | 'mod-data-export-worker' |

    * table exportModulesPermissions
      | name                     |
      | 'data-export.job.all'    |
      | 'data-export.config.all' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: enable export modules and update permissions
    Given call read('classpath:common/tenant.feature@install') { modules: '#(exportModules)', tenant: '#(testTenant)'}
    Given call login testAdmin

    Given path 'perms/users'
    And param query = 'userId=00000000-1111-5555-9999-999999999992'
    And headers {'x-okapi-tenant':'#(testTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And def permissionEntry = $.permissionUsers[0]
    And def newPermissions = $exportModulesPermissions[*].name
    And def updatedPermissions = karate.append(permissionEntry.permissions, newPermissions)
    And set permissionEntry.permissions = updatedPermissions

    Given path 'perms/users', permissionEntry.id
    And headers {'x-okapi-tenant':'#(testTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request permissionEntry
    When method PUT
    Then status 200

  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:global/mod_inventory_init_data.feature')
    * callonce read('classpath:global/mod_data_export_init_data.feature')
