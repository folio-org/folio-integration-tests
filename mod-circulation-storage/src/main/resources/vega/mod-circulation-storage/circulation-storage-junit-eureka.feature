Feature: mod-circulation-storage integration tests

  Background:
    * url baseUrl

    * table userPermissions
      | name                                                      |
      | 'inventory-storage.service-points.item.post'              |
      | 'inventory-storage.service-points.item.put'               |
      | 'circulation-storage.request-policies.item.post'          |
      | 'circulation-storage.request-policies.item.put'           |
      | 'print-events-storage.print-events-entry.item.post'       |
      | 'circulation-storage.circulation-settings.item.post'      |
      | 'circulation-storage.circulation-settings.item.get'       |
      | 'circulation-storage.circulation-settings.item.put'       |
      | 'circulation-storage.circulation-settings.item.delete'    |
      | 'circulation-storage.circulation-settings.collection.get' |
      | 'print-events-storage.print-events-status.item.post'      |
      | 'users.item.post'                                         |
      | 'login.item.post'                                         |
      | 'perms.permissions.get'                                   |
      | 'perms.users.item.post'                                   |



  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
