Feature: mod-data-export-spring integration tests

  Background:
    * url baseUrl
    * configure readTimeout = 300000
    * callonce login admin

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-invoice-storage'       |
      | 'mod-invoice'               |
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-organizations-storage' |
      | 'mod-organizations'         |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-audit'                 |

    * table userPermissions
      | name                                                    |
      | 'orders.all'                                            |
      | 'audit.all'                                             |
      | 'orders-storage.titles.collection.get'                  |
      | 'orders-storage.pieces-batch.collection.put'            |
      | 'pieces.send-claims.collection.post'                    |
      | 'acquisitions-units-storage.units.collection.get'       |
      | 'acquisitions-units-storage.memberships.collection.get' |
      | 'finance-storage.funds.item.post'                       |
      | 'finance.budgets.item.post'                             |
      | 'configuration.entries.item.get'                        |
      | 'organizations.module.all'                              |


    * table exportModules
      | name                     |
      | 'mod-data-export-spring' |
      | 'mod-data-export-worker' |

    * table exportModulesPermissions
      | name                           |
      | 'data-export.job.all'          |
      | 'data-export.config.all'       |
      | 'data-export.config.item.post' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: enable export modules
    # get and install export modules
    Given call read('classpath:common/tenant.feature@install') { modules: '#(exportModules)', tenant: '#(testTenant)'}
    And pause(300000)

  Scenario: update user permissions with export modules permissions
    * call login testAdmin
    Given path 'perms/users'
    And param query = 'userId=00000000-1111-5555-9999-999999999992'
    And headers {'x-okapi-tenant':'#(testTenant)', 'x-okapi-token':'#(okapitoken)'}
    When method GET
    Then status 200

    And def permissionEntry = $.permissionUsers[0]
    And def newPermissions = $exportModulesPermissions[*].name
    And def updatedPermissions = karate.append(permissionEntry.permissions, newPermissions)
    And set permissionEntry.permissions = updatedPermissions

    # update user permissions with export modules permissions
    Given path 'perms/users', permissionEntry.id
    And headers {'x-okapi-tenant':'#(testTenant)', 'x-okapi-token':'#(okapitoken)'}
    And request permissionEntry
    When method PUT
    Then status 200

  Scenario: init global data
    * call login testAdmin
    * callonce read('classpath:global/inventory.feature')
    * callonce read('classpath:global/configuration.feature')
    * callonce read('classpath:global/finances.feature')
    * callonce read('classpath:global/organizations.feature')