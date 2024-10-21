Feature: mod-source-record-storage integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-source-record-storage' |
      | 'mod-inventory'             |

    * table userPermissions
      | name                                                            |
      | 'source-storage.stream.marc-record-identifiers.collection.post'  |
      | 'source-storage.records.collection.get'                         |
      | 'source-storage.records.item.get'                               |
      | 'source-storage.records.formatted.item.get'                     |
      | 'source-storage.stream.records.collection.get'                  |
      | 'source-storage.records.matching.collection.post'               |
      | 'source-storage.records.post'                                   |
      | 'source-storage.records.put'                                    |
      | 'source-storage.records.generation.item.put'                   |
      | 'source-storage.records.update'                                 |
      | 'source-storage.records.delete'                                 |
      | 'source-storage.snapshots.item.get'                             |
      | 'source-storage.snapshots.collection.get'                       |
      | 'source-storage.snapshots.post'                                 |
      | 'source-storage.snapshots.put'                                  |
      | 'source-storage.stream.source-records.collection.get'           |
      | 'source-storage.source-records.item.get'                        |
      | 'source-storage.source-records.collection.get'                  |
      | 'inventory-storage.instances.item.post'                         |
      | 'inventory-storage.instance-types.item.post'                    |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')