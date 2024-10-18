Feature: mod-source-record-storage integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-entities-links'        |
      | 'mod-source-record-manager' |
      | 'mod-inventory-storage'     |

    * table userPermissions
      | name                                                        |
      | 'mapping-rules.get'                                         |
      | 'mapping-rules.update'                                      |
      | 'mapping-rules.restore'                                     |
      | 'change-manager.jobexecutions.post'                         |
      | 'change-manager.jobExecutions.item.get'                     |
      | 'change-manager.jobExecutions.children.collection.get'      |
      | 'change-manager.jobExecutions.item.put'                     |
      | 'change-manager.jobExecutions.status.item.put'              |
      | 'change-manager.jobExecutions.jobProfile.item.put'           |
      | 'change-manager.records.post'                               |
      | 'metadata-provider.jobLogEntries.collection.get'            |
      | 'metadata-provider.jobLogEntries.records.item.get'          |
      | 'metadata-provider.journalRecords.collection.get'           |
      | 'metadata-provider.jobSummary.item.get'                     |
      | 'metadata-provider.jobExecutions.collection.get'            |
      | 'metadata-provider.jobExecutions.users.collection.get'      |
      | 'metadata-provider.jobExecutions.jobProfiles.collection.get' |
      | 'mapping-metadata.item.get'                                 |
      | 'mapping-metadata.type.item.get'                            |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')