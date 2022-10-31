Feature: mod-calendar integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-calendar'                      |
      | 'mod-inventory-storage'             |

    * table userPermissions
      | name                                          |
      | 'calendar.view'                               |
      | 'calendar.create'                             |
      | 'calendar.update'                             |
      | 'calendar.delete'                             |
      | 'inventory-storage.service-points.item.post'  |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
