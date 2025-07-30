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
      | name                                                      |
      | 'rtac.batch.post'                                         |
      | 'inventory-storage.instance-types.item.post'              |
      | 'inventory-storage.contributor-name-types.item.post'      |
      | 'inventory-storage.service-points.item.post'              |
      | 'inventory-storage.location-units.institutions.item.post' |
      | 'inventory-storage.location-units.campuses.item.post'     |
      | 'inventory-storage.location-units.libraries.item.post'    |
      | 'inventory-storage.locations.item.post'                   |
      | 'inventory-storage.holdings-sources.item.post'            |
      | 'inventory-storage.holdings.item.post'                    |
      | 'inventory-storage.material-types.item.post'              |
      | 'inventory-storage.material-types.item.delete'            |
      | 'inventory.items.item.delete'                             |
      | 'inventory-storage.loan-types.item.post'                  |
      | 'inventory.instances.item.post'                           |
      | 'inventory.items.item.post'                               |
      | 'users.item.post'                                         |
      | 'perms.users.item.post'                                   |
      | 'configuration.entries.item.post'                         |
      | 'finance.fiscal-years.item.post'                          |
      | 'finance-storage.ledgers.item.post'                       |
      | 'finance-storage.funds.item.post'                         |
      | 'finance.budgets.item.post'                               |
      | 'finance.expense-classes.item.post'                       |
      | 'organizations-storage.organizations.item.post'           |
      | 'orders.acquisition-method.item.post'                     |
      | 'orders.item.post'                                        |
      | 'orders.item.get'                                         |
      | 'orders.po-lines.item.post'                               |
      | 'orders.item.put'                                         |
      | 'orders.pieces.collection.get'                            |
      | 'orders.titles.collection.get'                            |
      | 'orders.pieces.item.post'                                 |
      | 'orders.pieces.item.post'                                 |
      | 'finance.funds.collection.get'                            |
      | 'finance.ledgers.current-fiscal-year.item.get'            |
      | 'finance.budgets.collection.get'                          |
      | 'finance.transactions.collection.get'                     |

    * def testTenant = 'testrtac'
    * def testUser = { tenant: '#(testTenant)', name: 'test-user', password: 'test' }

  Scenario: create tenant and users for testing
    * call read('classpath:common/eureka/setup-users.feature') { testTenant: '#(testTenant)', testUser: #(testUser) }
