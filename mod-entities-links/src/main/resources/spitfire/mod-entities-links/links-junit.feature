Feature: mod-notes integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-entities-links'        |
      | 'mod-source-record-manager' |
      | 'mod-source-record-storage' |
      | 'mod-inventory'             |
      | 'mod-inventory-storage'     |

    * table userPermissions
      | name                                                 |
      | 'instance-authority.linking-rules.collection.get'    |
      | 'instance-authority.linking-rules.item.get'          |
      | 'instance-authority.linking-rules.item.patch'        |
      | 'instance-authority-links.instances.collection.get'  |
      | 'instance-authority-links.instances.collection.put'  |
      | 'inventory-storage.authorities.collection.get'       |
      | 'inventory-storage.authorities.item.delete'          |
      | 'inventory-storage.authorities.item.get'             |
      | 'inventory-storage.authorities.item.post'            |
      | 'inventory-storage.authorities.item.put'             |
      | 'inventory-storage.authority-source-files.item.post' |
      | 'inventory-storage.instance-types.item.post'         |
      | 'inventory-storage.instances.item.post'              |
      | 'source-storage.records.item.get'                    |
      | 'source-storage.records.post'                        |
      | 'source-storage.snapshots.post'                      |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')