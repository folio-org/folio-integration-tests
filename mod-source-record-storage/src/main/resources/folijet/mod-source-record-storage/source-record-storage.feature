Feature: mod-source-record-storage integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-source-record-storage' |

    * table userPermissions
      | name                               |
      | 'source-storage.records.get'       |
      | 'source-storage.records.post'      |
      | 'source-storage.records.put'       |
      | 'source-storage.records.update'    |
      | 'source-storage.records.delete'    |
      | 'source-storage.snapshots.get'     |
      | 'source-storage.snapshots.post'    |
      | 'source-storage.snapshots.put'     |
      | 'source-storage.sourceRecords.get' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')