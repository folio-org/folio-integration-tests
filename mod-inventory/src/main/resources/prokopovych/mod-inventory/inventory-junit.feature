Feature: mod-inventory integration tests

  Background:
    * url baseUrl
    * table modules
      | name                    |
      | 'okapi'                 |
      | 'mod-login'             |
      | 'mod-permissions'       |
      | 'mod-inventory'         |
      | 'mod-inventory-storage' |

    * table userPermissions
      | name                                                      |
      | 'inventory.items.item.post'                               |
      | 'inventory.items.move.item.post'                          |
      | 'inventory.instances.item.get'                            |
      | 'inventory.instances.item.post'                           |
      | 'inventory.instances.collection.get'                      |
      | 'inventory.holdings.move.item.post'                       |
      | 'inventory-storage.holdings.item.post'                    |
      | 'inventory-storage.holdings.item.delete'                  |
      | 'inventory-storage.locations.item.post'                   |
      | 'inventory-storage.authority-source-files.collection.get' |
      | 'inventory-storage.authority-source-files.item.get'       |
      | 'inventory-storage.authority-source-files.item.post'      |
      | 'inventory-storage.authority-source-files.item.put'       |
      | 'inventory-storage.authority-source-files.item.delete'    |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
