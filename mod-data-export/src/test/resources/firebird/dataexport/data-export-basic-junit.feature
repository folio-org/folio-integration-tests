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
      | 'mod-linked-data'           |
      | 'mod-fqm-manager'           |

    * table userPermissions
      | name                                                           |
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
      | 'data-export.mapping-profiles.item.post'                       |
      | 'data-export.mapping-profiles.item.put'                        |
      | 'data-export.mapping-profiles.item.get'                        |
      | 'data-export.mapping-profiles.item.delete'                     |
      | 'data-export.mapping-profiles.collection.get'                  |
      | 'inventory-storage.instance-types.item.post'                   |
      | 'inventory-storage.holdings-types.item.post'                   |
      | 'inventory-storage.identifier-types.item.post'                 |
      | 'inventory-storage.holdings-sources.item.post'                 |
      | 'inventory-storage.locations.item.post'                        |
      | 'inventory-storage.location-units.campuses.item.post'          |
      | 'inventory-storage.location-units.libraries.item.post'         |
      | 'inventory-storage.location-units.institutions.item.post'      |
      | 'inventory-storage.instances.item.post'                        |
      | 'inventory-storage.holdings.item.post'                         |
      | 'inventory-storage.items.item.post'                            |
      | 'source-storage.snapshots.post'                                |
      | 'source-storage.records.post'                                  |
      | 'inventory-storage.instance.reindex.post'                      |
      | 'inventory-storage.instance.reindex.collection.get'            |
      | 'inventory-storage.instance.reindex.item.get'                  |
      | 'data-export.job-profiles.collection.get'                      |
      | 'data-export.job-profiles.item.get'                            |
      | 'data-export.job-profiles.item.post'                           |
      | 'data-export.job-profiles.item.put'                            |
      | 'data-export.job-profiles.item.delete'                         |
      | 'data-export.file-definitions.item.get'                        |
      | 'data-export.file-definitions.item.post'                       |
      | 'data-export.file-definitions.upload.post'                     |
      | 'data-export.export.post'                                      |
      | 'data-export.job-executions.collection.get'                    |
      | 'data-export.job-executions.items.download.get'                |
      | 'data-export.logs.collection.get'                              |
      | 'data-export.transformation-fields.collection.get'             |
      | 'data-export.clean-up-files.post'                              |
      | 'data-export.quick.export.post'                                |
      | 'data-export.job.item.download'                                |
      | 'data-export.job.item.get'                                     |
      | 'data-export.job.item.post'                                    |
      | 'marc-records-editor.item.get'                                 |
      | 'marc-records-editor.item.put'                                 |
      | 'data-export.export-deleted.post'                              |
      | 'data-export.export-authority-deleted.post'                    |
      | 'data-export.job.collection.get'                               |
      | 'data-export.job-executions.item.delete'                       |
      | 'linked-data.resources.import.post'                            |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/eureka/setup-users.feature')

  Scenario: init global data
    * callonce read('classpath:global/mod_inventory_init_data.feature')
    * callonce read('classpath:global/mod_data_export_init_data.feature')