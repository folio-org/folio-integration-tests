@parallel=false
Feature: edge-orders integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-login'                 |
      | 'mod-users'                 |
      | 'mod-organizations-storage' |
      | 'mod-organizations'         |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-finance-storage'       |
      | 'mod-finance'               |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-ebsconet'              |
      | 'mod-gobi'                  |

    * table userPermissions
      | name           |
      | 'orders-storage.routing-lists.item.post' |
      | 'orders-storage.settings.item.post' |
      | 'orders-storage.po-lines.item.put' |
      | 'orders.re-encumber.item.post' |
      | 'orders-storage.po-lines.item.post' |
      | 'orders.bind-pieces.item.delete' |
      | 'orders-storage.po-lines.item.get' |
      | 'orders.item.reopen' |
      | 'orders.routing-lists.item.put' |
      | 'orders.titles.item.get' |
      | 'orders.routing-lists.item.delete' |
      | 'orders.routing-lists.collection.get' |
      | 'orders.bind-pieces.collection.post' |
      | 'orders.routing-lists.item.post' |
      | 'orders.routing-lists.item.get' |
      | 'orders-storage.claiming.process.execute' |
      | 'orders.item.unopen' |
      | 'orders.pieces.item.put' |
      | 'orders.titles.item.post' |
      | 'orders.pieces.item.get' |
      | 'orders.acquisitions-units-assignments.assign' |
      | 'orders.pieces.collection.post' |
      | 'orders.pieces.collection.put' |
      | 'orders.titles.item.put' |
      | 'orders.pieces.item.delete' |
      | 'orders.pieces.item.post' |
      | 'orders.po-lines.item.put' |
      | 'orders.acquisitions-units-assignments.manage' |
      | 'orders.po-lines.item.delete' |
      | 'orders.item.delete' |
      | 'orders-storage.pieces.collection.get' |
      | 'orders.acquisition-method.item.post' |
      | 'orders.po-lines.item.get' |
      | 'orders.pieces.collection.get' |
      | 'orders.receiving.collection.post' |
      | 'orders.check-in.collection.post' |
      | 'orders.titles.collection.get' |
      | 'orders-storage.titles.item.get' |
      | 'orders.collection.get' |
      | 'orders.item.get' |
      | 'orders.item.post' |
      | 'orders.item.put' |
      | 'orders.po-lines.collection.get' |
      | 'orders.po-lines.item.post' |
      | 'organizations-storage.organizations.item.post' |
      | 'organizations.organizations.item.get' |
      | 'organizations.organizations.item.post' |
      | 'organizations.organizations.item.put' |
      | 'configuration.entries.collection.get' |
      | 'configuration.entries.item.delete' |
      | 'configuration.entries.item.post' |
      | 'configuration.entries.item.put' |
      | 'inventory.items.move.item.post' |
      | 'inventory.holdings.move.item.post' |
      | 'inventory-storage.holdings.item.get' |
      | 'inventory.items.item.get' |
      | 'inventory.tenant-items.collection.get' |
      | 'inventory.items.collection.get' |
      | 'inventory.items-by-holdings-id.collection.get' |
      | 'inventory.instances.collection.get' |
      | 'inventory-storage.holdings.retrieve.collection.post' |
      | 'inventory.instances.item.put' |
      | 'inventory-storage.locations.item.post' |
      | 'inventory-storage.holdings-sources.item.post' |
      | 'inventory-storage.service-points.item.post' |
      | 'inventory-storage.location-units.libraries.item.post' |
      | 'inventory-storage.location-units.campuses.item.post' |
      | 'inventory-storage.location-units.institutions.item.post' |
      | 'inventory-storage.electronic-access-relationships.item.post' |
      | 'inventory-storage.contributor-name-types.item.post' |
      | 'inventory-storage.material-types.item.post' |
      | 'inventory-storage.loan-types.item.post' |
      | 'inventory-storage.instance-statuses.item.post' |
      | 'inventory-storage.identifier-types.item.post' |
      | 'inventory-storage.instance-types.item.post' |
      | 'inventory-storage.holdings.item.post' |
      | 'inventory-storage.holdings.collection.get' |
      | 'inventory-storage.instances.item.get' |
      | 'inventory-storage.items.item.get' |
      | 'inventory.instances.item.post' |

    * def testTenant = 'testedgeorders'
    * def testAdmin = { tenant: '#(testTenant)', name: 'test-admin', password: 'admin' }
    * def testUser = { tenant: '#(testTenant)', name: 'test-user', password: 'test' }

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature') { testTenant: '#(testTenant)', testAdmin: #(testAdmin), testUser: #(testUser) }

  Scenario: init global data
    * call login testAdmin
    * callonce read('classpath:global/inventory.feature') { testAdmin: #(testAdmin) }
    * callonce read('classpath:global/configuration.feature') { testAdmin: #(testAdmin) }
    * callonce read('classpath:global/finances.feature') { testAdmin: #(testAdmin) }
    * callonce read('classpath:global/organizations.feature') { testAdmin: #(testAdmin) }
