Feature: mod-patron-blocks integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-patron-blocks'                 |
      | 'mod-inventory'                     |
      | 'mod-inventory-storage'             |

    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                        |
      | 'patron-block-limits.item.get'              |
      | 'patron-block-limits.item.post'             |
      | 'patron-block-limits.item.put'              |
      | 'patron-block-limits.item.delete'           |
      | 'usergroups.item.post'                      |
      | 'users.item.post'                           |
      | 'inventory.items.item.post'                 |
      | 'inventory.instances.item.post'             |
      | 'inventory-storage.instance-types.item.post'|
      | 'inventory-storage.holdings.item.post'      |
      | 'inventory-storage.locations.item.post'     |
      | 'inventory-storage.location-units.institutions.item.post'     |
      | 'inventory-storage.location-units.campuses.item.post'     |
      | 'inventory-storage.location-units.libraries.item.post'     |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
