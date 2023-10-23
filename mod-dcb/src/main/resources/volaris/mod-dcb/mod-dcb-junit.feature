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
      | 'usergroups.item.post'                                   |




  Scenario: create tenant and users for testing for mod-dcb
    Given call read('classpath:common/setup-users.feature')
