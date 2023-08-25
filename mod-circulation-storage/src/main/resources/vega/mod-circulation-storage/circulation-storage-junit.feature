Feature: mod-circulation integration tests

  Background:
    * url baseUrl
    * table modules
      | name                      |
      | 'mod-circulation-storage' |
      | 'mod-inventory-storage'   |

    * table userPermissions
      | name                                                |
      | 'inventory-storage.service-points.item.post'        |
      | 'inventory-storage.service-points.item.put'         |
      | 'circulation-storage.request-policies.item.post'    |
      | 'circulation-storage.request-policies.item.put'     |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')