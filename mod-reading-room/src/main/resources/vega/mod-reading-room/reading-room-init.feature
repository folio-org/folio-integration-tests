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
      | name                                              |
      | 'inventory-storage.service-points.collection.get' |
      | 'inventory-storage.service-points.item.post'      |
      | 'reading-room.access-log.collection.get'          |
      | 'reading-room.access-log.post'                    |
      | 'reading-room.collection.get'                     |
      | 'reading-room.item.delete'                        |
      | 'reading-room.item.post'                          |
      | 'reading-room.item.put'                           |
      | 'reading-room.patron-permission.item.get'         |
      | 'reading-room.patron-permission.item.put'         |
      | 'usergroups.item.post'                            |
      | 'users.item.get'                                  |
      | 'users.item.post'                                 |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')