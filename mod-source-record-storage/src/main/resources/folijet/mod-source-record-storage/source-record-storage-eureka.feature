Feature: mod-source-record-storage integration tests

  Background:
    * url baseUrl

    * table userPermissions
      | name                                           |
      | 'source-storage.records.collection.get'        |
      | 'source-storage.records.item.get'              |
      | 'source-storage.records.post'                  |
      | 'source-storage.records.put'                   |
      | 'source-storage.records.delete'                |
      | 'source-storage.snapshots.post'                |
      | 'source-storage.snapshots.put'                 |
      | 'source-storage.source-records.item.get'       |
      | 'source-storage.source-records.collection.get' |
      | 'inventory-storage.instances.item.post'        |
      | 'inventory-storage.instance-types.item.post'   |

    * def requiredApplications = ['app-platform-complete', 'app-platform-minimal']

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')