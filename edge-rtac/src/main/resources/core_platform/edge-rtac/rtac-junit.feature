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
      | 'mod-orders'              |
      | 'mod-organizations'       |
      | 'mod-configuration'       |

    * table userPermissions
      | name                                            |
      | 'rtac.batch.post'                               |
      | 'inventory-storage.all'                         |
      | 'inventory.instances.item.post'                 |
      | 'inventory.items.item.post'                     |
      | 'users.item.post'                               |
      | 'perms.users.item.post'                         |
      | 'configuration.entries.item.post'               |
      | 'finance.fiscal-years.item.post'                |
      | 'finance-storage.ledgers.item.post'             |
      | 'finance-storage.funds.item.post'               |
      | 'finance.budgets.item.post'                     |
      | 'finance.expense-classes.item.post'             |
      | 'organizations-storage.organizations.item.post' |
      | 'orders.acquisition-method.item.post'           |
      | 'orders.item.post'                              |
      | 'orders.item.get'                               |
      | 'orders.po-lines.item.post'                     |
      | 'orders.item.put'                               |

    * def testTenant = 'testrtac'
    * def testUser = { tenant: '#(testTenant)', name: 'test-user', password: 'test' }

  Scenario: create tenant and users for testing
    * call read('classpath:common/setup-users.feature') { testTenant: '#(testTenant)', testUser: #(testUser) }
