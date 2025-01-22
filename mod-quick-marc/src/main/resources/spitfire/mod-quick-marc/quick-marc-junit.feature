Feature: mod-quick-marc integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-configuration'         |
      | 'mod-quick-marc'            |
      | 'mod-source-record-manager' |
      | 'mod-source-record-storage' |
      | 'mod-inventory'             |
      | 'mod-inventory-storage'     |
      | 'mod-entities-links'        |
      | 'mod-record-specifications' |

    * table userPermissions
      | name                                                           |
      | 'configuration.all'                                            |
      | 'inventory-storage.all'                                        |
      | 'inventory-storage.authorities.all'                            |
      | 'source-storage.all'                                           |
      | 'marc-records-editor.all'                                      |
      | 'metadata-provider.jobLogEntries.collection.get'               |
      | 'metadata-provider.jobLogEntries.records.item.get'             |
      | 'metadata-provider.journalRecords.collection.get'              |
      | 'metadata-provider.jobSummary.item.get'                        |
      | 'change-manager.jobExecutions.item.get'                        |
      | 'change-manager.jobExecutions.children.collection.get'         |
      | 'converter-storage.field-protection-settings.item.get'         |
      | 'converter-storage.field-protection-settings.collection.get'   |
      | 'instance-authority-links.instances.collection.put'            |
      | 'instance-authority-links.instances.collection.get'            |
      | 'instance-authority-links.authorities.bulk.post'               |
      | 'inventory-storage.authority-source-files.item.post'           |
      | 'specification-storage.specification.item.sync.execute'        |
      | 'specification-storage.all'                                    |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
