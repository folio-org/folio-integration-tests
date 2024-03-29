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
      | 'source-storage.snapshots.post'                           |
      | 'source-storage.records.post'                             |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: create locations
    Given call read('classpath:folijet/mod-inventory/features/locations.feature')
