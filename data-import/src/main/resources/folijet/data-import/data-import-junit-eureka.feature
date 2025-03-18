Feature: mod-data-import integration tests

  Background:
    * url baseUrl
    * configure readTimeout = 300000

    * table userPermissions
      | name                                                        |
      |'inventory.instances.collection.get'|
      |'inventory.instances.item.put'|
      |'inventory.instances.item.get'|
      |'inventory-storage.instances.collection.get'|
      |'inventory-storage.instance-types.item.post'|
      |'inventory-storage.holdings-types.item.post'|
      |'inventory-storage.identifier-types.item.post'|
      |'inventory-storage.locations.item.post'|
      |'inventory-storage.location-units.campuses.item.post'|
      |'inventory-storage.location-units.libraries.item.post'|
      |'inventory-storage.location-units.institutions.item.post'|
      |'inventory-storage.call-number-types.item.post'|
      |'inventory-storage.loan-types.item.post'|
      |'inventory-storage.material-types.item.post'|
      |'inventory-storage.statistical-code-types.item.post'|
      |'inventory-storage.statistical-codes.item.post'|
      |'inventory-storage.electronic-access-relationships.item.post'|
      |'inventory-storage.instance-statuses.item.post'|
      |'inventory-storage.item-note-types.item.post'|
      |'inventory-storage.ill-policies.item.post'|
      |'inventory-storage.holdings-sources.item.post'|
      |'inventory-storage.holdings.collection.get'|
      |'inventory-storage.holdings-sources.item.get'|
      |'inventory-storage.instances.item.post'|
      |'inventory-storage.holdings.item.post'|
      |'inventory-storage.items.item.post'|
      |'inventory-storage.identifier-types.collection.get'|
      |'inventory.items.collection.get'|
      |'inventory.items.item.get'|
      |'configuration.entries.item.post'|
      |'organizations-storage.organizations.item.post'|
      |'source-storage.source-records.collection.get'|
      |'source-storage.source-records.item.get'|
      |'source-storage.records.formatted.item.get'|
      |'source-storage.records.item.get'|
      |'data-export.file-definitions.item.post'|
      |'data-export.file-definitions.upload.post'|
      |'data-export.file-definitions.item.get'|
      |'data-export.export.post'|
      |'data-export.job-executions.collection.get'|
      |'data-export.job-executions.items.download.get'|
      |'data-export.job-profiles.item.post'|
      |'data-export.mapping-profiles.item.post'|
      |'data-export.quick.export.post'|
      | 'data-import.assembleStorageFile.post'                      |
      | 'data-import.splitconfig.get'                                |
      | 'data-import.uploaddefinitions.post'                         |
      | 'data-import.uploadDefinitions.item.get'                     |
#      | 'data-import.uploadDefinitions.collection.get'               |
#      | 'data-import.uploaddefinitions.put'                          |
#      | 'data-import.uploaddefinitions.delete'                       |
      | 'data-import.upload.file.post'                               |
#      | 'data-import.uploaddefinitions.files.delete'                  |
      | 'data-import.uploadDefinitions.files.item.post'               |
      | 'data-import.uploadDefinitions.processFiles.item.post'       |
      | 'data-import.fileExtensions.item.get'                        |
      | 'data-import.fileExtensions.collection.get'                  |
      | 'data-import.fileExtensions.post'                            |
      | 'data-import.fileExtensions.put'                             |
      | 'data-import.fileExtensions.delete'                          |
      | 'data-import.fileExtensions.default.post'                    |
#      | 'data-import.datatypes.get'                                 |
      | 'data-import.uploadUrl.item.get'                            |
#      | 'data-import.uploadUrl.subsequent.item.get'                 |
#      | 'data-import.downloadUrl.get'                               |
#      | 'data-import.jobexecution.cancel'                           |
#      | 'data-import.upload.all'                                    |
#      | 'configuration.all'                                          |
#      | 'inventory-storage.all'                                     |
#      | 'source-storage.all'                                        |
#      | 'converter-storage.jobprofile.item.get'                      |
#      | 'converter-storage.jobprofile.collection.get'                |
      | 'converter-storage.jobprofile.post'                          |
      | 'converter-storage.jobprofile.delete'                        |
      | 'converter-storage.actionprofile.post'                       |
      | 'converter-storage.actionprofile.delete'                     |
      | 'converter-storage.mappingprofile.post'                      |
      | 'converter-storage.mappingprofile.delete'                    |
      | 'change-manager.jobExecutions.item.get'                     |
      | 'change-manager.jobExecutions.children.collection.get'      |
      | 'change-manager.jobexecutions.delete'                       |
#      | 'inventory.all'                                             |
      | 'metadata-provider.jobLogEntries.collection.get'            |
      | 'metadata-provider.jobLogEntries.records.item.get'          |
#      | 'metadata-provider.journalRecords.collection.get'           |
#      | 'metadata-provider.jobSummary.item.get'                     |
      | 'converter-storage.matchprofile.post'                        |
#      | 'data-export.all'                                           |
#      | 'invoice.all'                                               |
      | 'mapping-rules.get'                                         |
      | 'mapping-rules.update'                                      |
      | 'invoice-storage.invoice-lines.collection.get'              |
#      | 'invoice-storage.invoice-lines.item.get'                    |
      | 'invoice-storage.invoices.item.get'                         |
#      | 'organizations-storage.organizations.all'                   |
#      | 'orders.all'                                                |
      |'orders.item.post'|
      |'orders.item.get'|
      |'orders.item.put'|
      |'orders.po-lines.item.post'|
      |'orders.po-lines.item.get'|
#      | 'orders-storage.titles.item.get'                            |
      | 'acquisitions-units-storage.memberships.item.post'          |
      | 'acquisitions-units-storage.units.item.post'                |
#      | 'copycat.profiles.collection.get'                            |
      | 'copycat.imports.post'                                      |
      | 'copycat.profiles.item.put'                                  |
      | 'metadata-provider.jobExecutions.collection.get'            |
#      | 'metadata-provider.jobExecutions.users.collection.get'      |
#      | 'metadata-provider.jobExecutions.jobProfiles.collection.get' |
#      | 'organizations.organizations.collection.get'                |
      | 'inventory-storage.authorities.item.get'                    |
#      | 'converter-storage.all'                                     |
      |'converter-storage.actionprofile.collection.get'|
      | 'marc-records-editor.item.get'                              |

    * def requiredApplications = ['app-platform-complete', 'app-platform-minimal', 'app-acquisitions', 'app-fqm']

  Scenario: create tenant and users for testing
    * call read('classpath:common/eureka/setup-users.feature')

  Scenario: init global data
    * call login testUser

    * callonce read('classpath:folijet/data-import/eureka-global/mod_inventory_init_data.feature')
    * callonce read('classpath:folijet/data-import/eureka-global/init-acquisition-data.feature')