Feature: mod-inventory integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'okapi'                             |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-inventory'                     |
      | 'mod-inventory-storage'             |


    * table adminAdditionalPermissions
      | name                                |

    * table userPermissions
      | name                                                             |
      |'inventory.items.item.post'                                       |
      |'inventory.instances.item.post'                                   |
      |'inventory-storage.holdings.item.post'                            |
      |'inventory-storage.holdings.item.delete'                          |

  Scenario: create tenant and users for testing
      Given call read('classpath:common/setup-users.feature')
