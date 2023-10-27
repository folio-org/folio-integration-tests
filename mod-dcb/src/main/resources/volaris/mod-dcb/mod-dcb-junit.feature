Feature: mod-dcb integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-users'                 |
      | 'mod-dcb'                   |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |


    * table userPermissions
      | name                                                       |
      | 'users.collection.get'                                     |
      | 'usergroups.collection.get'                                |
      | 'usergroups.item.post'                                     |
      | 'users.item.post'                                          |
      | 'inventory-storage.service-points.item.post'               |
      | 'inventory-storage.items.item.get'                         |
      | 'inventory.items.item.post'                                |
      | 'inventory.instances.item.post'                            |
      | 'inventory-storage.instance-types.item.post'               |
      | 'inventory-storage.contributor-name-types.item.post'       |
      | 'inventory-storage.holdings.item.post'                     |





  Scenario: create tenant and users for testing for mod-dcb
    Given call read('classpath:common/setup-users.feature')
