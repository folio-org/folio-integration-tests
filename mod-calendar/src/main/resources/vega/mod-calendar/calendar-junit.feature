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
      | 'calendar.opening-hours.collection.get'       |
      | 'calendar.periods.item.post'                  |
      | 'calendar.periods.collection.get'             |
      | 'inventory-storage.service-points.item.post'  |
      | 'calendar.periods.item.get'                   |
      | 'calendar.periods.item.delete'                |
      | 'calendar.periods.item.put'                   |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
