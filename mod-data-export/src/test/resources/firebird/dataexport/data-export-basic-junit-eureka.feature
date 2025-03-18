Feature: mod-orders integration tests

  Background:
    * url baseUrl
    * configure readTimeout = 600000

    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-data-export'           |
      | 'mod-login'                 |
      | 'mod-configuration'         |
      | 'mod-source-record-manager' |
      | 'mod-source-record-storage' |
      | 'mod-inventory-storage'     |
      | 'mod-inventory'             |
      | 'mod-entities-links'        |
      | 'mod-quick-marc'            |
      | 'mod-users'                 |
      | 'mod-data-export-spring'    |
      | 'mod-data-export-worker'    |

    * table userPermissions
      | name                                                           |
      | 'data-export.all'                                              |
      | 'configuration.all'                                            |
      | 'inventory-storage.all'                                        |
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
      | 'inventory.instances.collection.get'                           |
      | 'instance-authority-links.authority-statistics.collection.get' |
      | 'users.item.get'                                               |
      | 'inventory-storage.authorities.item.post'                      |
      | 'inventory-storage.authorities.item.delete'                    |
      | 'data-export.job.all'                                          |
      | 'data-export.config.all'                                       |
      | 'data-export.mapping-profiles.item.post'                       |
      | 'data-export.mapping-profiles.item.put'                       |
      | 'data-export.mapping-profiles.item.get'                       |
      | 'data-export.mapping-profiles.item.delete'                       |
    |'data-export.mapping-profiles.collection.get'|

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')

  Scenario: init global data
    * callonce read('classpath:global/mod_inventory_init_data.feature')
    * callonce read('classpath:global/mod_data_export_init_data.feature')
