Feature: mod-notes integration tests

  Background:
    * url baseUrl

    * table userPermissions
      | name                                                 |
      | 'inventory-storage.instance-types.item.post'         |
      | 'source-storage.snapshots.post'                      |
      | 'inventory-storage.instances.item.post'              |
      | 'inventory-storage.authority-source-files.item.post' |
      | 'inventory-storage.authorities.item.post'            |
      | 'source-storage.records.post'                        |
      | 'instance-authority-links.instances.collection.put'  |
      | 'instance-authority-links.instances.collection.get'  |
      | 'instance-authority-links.authorities.bulk.post'     |
      | 'inventory-storage.authorities.item.delete'          |
      | 'inventory-storage.authorities.item.get'             |
      | 'inventory-storage.authorities.item.put'             |
      | 'source-storage.records.item.get'                    |
      | 'inventory-storage.authorities.collection.get'       |
      | 'instance-authority.linking-rules.collection.get'    |
      | 'instance-authority.linking-rules.item.get'          |
      | 'instance-authority.linking-rules.item.patch'        |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')