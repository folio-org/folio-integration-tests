Feature: mod-reading-room integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-users'                 |
      | 'mod-inventory-storage'     |
      | 'mod-reading-room'          |

    * table userPermissions
      | name                                     |
      | 'reading-room.item.post'                 |
      | 'reading-room.collection.get'            |
      | 'reading-room.item.put'                  |
      | 'reading-room.item.delete'               |
      | 'reading-room.access-log.post'           |
      | 'reading-room.patron-permission.item.get'|
      | 'reading-room.patron-permission.item.put'|
      | 'inventory-storage.service-points.item.post' |
      | 'inventory-storage.service-points.collection.get'|
      | 'usergroups.item.post' |
      | 'users.item.post' |
      | 'users.item.get'|
      | 'reading-room.access-log.collection.get' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')