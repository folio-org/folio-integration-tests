Feature: edge-rtac integration tests

  Background:
    * url baseUrl
    * table modules
      | name                      |
      | 'mod-login'               |
      | 'mod-permissions'         |
      | 'mod-inventory'           |
      | 'mod-inventory-storage'   |
      | 'mod-rtac'                |
      | 'edge-rtac'               |

    * table userPermissions
      | name                                                      |
      | 'rtac.batch.post'                                         |
      | 'inventory-storage.all'                                   |
      | 'inventory.instances.item.post'                           |
      | 'inventory.items.item.post'                               |
      | 'users.item.post'                                         |
      | 'perms.users.item.post'                                   |

    * def testTenant = 'testrtac'
    * def testUser = { tenant: '#(testTenant)', name: 'test-user', password: 'test' }

  Scenario: create tenant and users for testing
    * call read('classpath:common/setup-users.feature') { testTenant: '#(testTenant)', testUser: #(testUser) }
