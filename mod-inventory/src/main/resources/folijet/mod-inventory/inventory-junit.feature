Feature: mod-inventory integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'okapi'                     |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-inventory'             |
      | 'mod-source-record-storage' |
      | 'mod-inventory-storage'     |

    * table userPermissions
      | name                                                      |
      | 'source-storage.records.get'                              |
      | 'inventory.items.item.post'                               |
      | 'inventory.items.move.item.post'                          |
      | 'inventory.instances.item.get'                            |
      | 'inventory.instances.item.post'                           |
      | 'inventory.instances.collection.get'                      |
      | 'inventory.holdings.move.item.post'                       |
      | 'inventory-storage.holdings.item.post'                    |
      | 'inventory-storage.holdings.item.delete'                  |
      | 'inventory-storage.service-points.item.post'              |
      | 'inventory-storage.location-units.campuses.item.post'     |
      | 'inventory-storage.location-units.institutions.item.post' |
      | 'inventory-storage.location-units.libraries.item.post'    |
      | 'inventory-storage.locations.item.post'                   |
      | 'inventory-storage.holdings-sources.item.post'            |
      | 'source-storage.snapshots.post'                           |
      | 'source-storage.records.post'                             |
      | 'inventory.holdings.update-ownership.item.post'           |
      | 'inventory.items.update-ownership.item.post'              |
      | 'user-tenants.collection.get'                             |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: create locations
    Given call read('classpath:folijet/mod-inventory/features/locations.feature')

  Scenario: create holdings source type
    * def testUser = karate.get('testUser')
    * print testUser
    * callonce login testUser
    * configure headers = { 'x-okapi-tenant':'#(testUser.tenant)','Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    * def holdingsSource =
      """
      {
        "id": "dc3fa469-d5e2-4b59-85d1-8b826e3219cf",
        "name": "TEST2",
        "source": "folio"
      }
      """
    * call read('classpath:folijet/mod-inventory/features/utils.feature@PostHoldingsSource') {holdingsSource: #(holdingsSource)}
