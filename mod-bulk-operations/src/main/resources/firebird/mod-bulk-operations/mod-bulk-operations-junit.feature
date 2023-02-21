Feature: bulk operations integration tests

  Background:
    * url baseUrl
    * table modules
      | name                     |
      | 'mod-login'              |
      | 'mod-permissions'        |
      | 'mod-inventory-storage'  |
      | 'mod-inventory'          |
      | 'mod-configuration'      |

    * table adminAdditionalPermissions
      | name                                         |
      | 'inventory-storage.all'                      |
      | 'inventory.items.item.post'                  |
      | 'inventory-storage.service-points.item.post' |

    * table userPermissions
      | name                           |

    * table testedModules
      | name                     |
      | 'mod-bulk-operations'    |

    * table testedModulesUserPermissions
      | name                                         |
      | 'users.collection.get'                       |
      | 'inventory.items.collection.get'             |
      | 'bulk-operations.all'                        |
      | 'data-export.job.item.post'                  |
      | 'bulk-edit.item.post'                        |
      | 'data-export.job.item.get'                   |
      | 'bulk-edit.start.item.post'                  |
      | 'usergroups.item.get'                        |
      | 'usergroups.collection.get'                  |
      | 'inventory-storage.holdings.collection.get'  |
      | 'configuration.entries.collection.get'       |
      | 'inventory-storage.holdings.item.get'        |
      | 'inventory-storage.locations.item.get'       |
      | 'inventory-storage.loan-types.item.get'      |
      | 'inventory-storage.holdings-sources.item.get'|
      | 'inventory-storage.instances.item.get'       |

  Scenario: create tenant and users for testing
    * pause(5000)
    Given call read('classpath:common/setup-users.feature')
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
