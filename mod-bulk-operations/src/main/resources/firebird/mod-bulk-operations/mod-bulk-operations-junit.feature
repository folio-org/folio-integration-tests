Feature: mod-audit integration tests

  Background:
    * url baseUrl
    * table modules
      | name                     |
      | 'mod-login'              |
      | 'mod-permissions'        |

    * table adminAdditionalPermissions
      | name                           |

    * table userPermissions
      | name                           |

    * table testedModules
      | name                     |
      | 'mod-bulk-operations'    |

    * table testedModulesUserPermissions
      | name                        |
      | 'bulk-operations.all'       |
      | 'data-export.job.item.post' |
      | 'bulk-edit.item.post'       |
      | 'data-export.job.item.get'  |
      | 'bulk-edit.start.item.post' |
      | 'usergroups.item.get'       |
      | 'users.collection.get'      |

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
