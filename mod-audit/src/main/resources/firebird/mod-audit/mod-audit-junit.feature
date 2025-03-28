Feature: mod-audit integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                     |
      | 'mod-login'                              |
      | 'mod-permissions'                        |
      | 'mod-audit'                              |
      | 'mod-circulation'                        |
      | 'mod-source-record-storage'              |

    * table adminAdditionalPermissions
      | name                                     |
      | 'overdue-fines-policies.item.post'        |
      | 'lost-item-fees-policies.item.post'      |

    * table userPermissions
      | name                                                  |
      | 'audit.all'                                           |
      | 'circulation.all'                                     |
      | 'manualblocks.collection.get'                         |
      | 'source-storage.records.post'                         |
      | 'source-storage.records.put'                          |
      | 'source-storage.snapshots.post'                       |
      | 'patron-blocks.automated-patron-blocks.collection.get'|

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
    Given call read('classpath:global/initTest.feature')