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
      |'inventory.instances.item.get'                                    |
      |'inventory.items.collection.get'                                   |
      |'inventory.instances.collection.get'                              |
      |'inventory-storage.instances.item.post'                           |
      |'inventory.instances.item.put'                                    |
      |'inventory-storage.instances.item.get'                            |
      |'inventory-storage.preceding-succeeding-titles.collection.get'    |
      |'inventory-storage.preceding-succeeding-titles.item.post'         |
      |'inventory-storage.preceding-succeeding-titles.item.put'          |
      |'inventory-storage.preceding-succeeding-titles.item.delete'       |
      |'inventory-storage.instance-relationships.collection.get'         |
      |'inventory-storage.instance-relationships.item.post'              |
      |'inventory-storage.instance-relationships.item.put'               |
      |'inventory-storage.instance-relationships.item.delete'            |
      |'inventory.instances.item.post'                                   |

  Scenario: create tenant and users for testing
      Given call read('classpath:common/setup-users.feature')
