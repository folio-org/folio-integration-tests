Feature: bulk operations integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-configuration'         |
      | 'mod-source-record-storage' |
      | 'mod-data-import'           |

    * table adminAdditionalPermissions
      | name                                         |
      | 'inventory-storage.all'                      |
      | 'inventory.items.item.post'                  |
      | 'inventory-storage.service-points.item.post' |

    * table userPermissions
      | name                           |

    * table testedModules
      | name                     |
      | 'mod-data-export-worker' |
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
      | 'inventory.instances.collection.get'         |
      | 'inventory-storage.holdings.item.put'        |
      | 'users.item.get'                             |
      | 'inventory.items.item.get'                   |
      | 'inventory-storage.holdings.item.get'        |
      | 'inventory.instances.item.get'               |
      | 'users.item.put'                             |
      | 'inventory.items.item.put'                   |
      | 'inventory-storage.holdings.item.put'        |
      | 'inventory.instances.item.put'               |
      | 'bulk-operations.item.inventory.get'         |
      | 'bulk-operations.item.users.get'             |
      | 'bulk-operations.item.inventory.put'         |
      | 'bulk-operations.item.users.put'             |
      | 'inventory-storage.contributor-types.collection.get' |
      | 'inventory-storage.instance-types.collection.get'    |
      | 'inventory-storage.instance-formats.collection.get'  |

  Scenario: create tenant and users for testing
    * pause(15000)
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
