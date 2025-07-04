Feature: mod-data-import integration tests

  Background:
    * url baseUrl
    * configure readTimeout = 300000

    * table modules
      | name                        |
      | 'mod-login'                 |
      | 'mod-permissions'           |
      | 'mod-users'                 |
      | 'mod-users-bl'              |
      | 'mod-configuration'         |
      | 'mod-source-record-storage' |
      | 'mod-source-record-manager' |
      | 'mod-inventory-storage'     |
      | 'mod-di-converter-storage'  |
      | 'mod-inventory'             |
      | 'mod-data-export'           |
      | 'mod-data-import'           |
      | 'mod-organizations-storage' |
      | 'mod-invoice'               |
      | 'mod-invoice-storage'       |
      | 'mod-orders-storage'        |
      | 'mod-orders'                |
      | 'mod-finance'               |
      | 'mod-finance-storage'       |
      | 'mod-copycat'               |
      | 'mod-organizations'         |
      | 'mod-entities-links'        |
      | 'mod-quick-marc'            |

    * table userPermissions
      | name                                                          |
      | 'inventory.instances.collection.get'                          |
      | 'inventory.instances.item.put'                                |
      | 'inventory.instances.item.get'                                |
      | 'inventory-storage.instances.collection.get'                  |
      | 'inventory-storage.instance-types.item.post'                  |
      | 'inventory-storage.holdings-types.item.post'                  |
      | 'inventory-storage.identifier-types.item.post'                |
      | 'inventory-storage.locations.item.post'                       |
      | 'inventory-storage.location-units.campuses.item.post'         |
      | 'inventory-storage.location-units.libraries.item.post'        |
      | 'inventory-storage.location-units.institutions.item.post'     |
      | 'inventory-storage.call-number-types.item.post'               |
      | 'inventory-storage.loan-types.item.post'                      |
      | 'inventory-storage.material-types.item.post'                  |
      | 'inventory-storage.statistical-code-types.item.post'          |
      | 'inventory-storage.statistical-codes.item.post'               |
      | 'inventory-storage.electronic-access-relationships.item.post' |
      | 'inventory-storage.instance-statuses.item.post'               |
      | 'inventory-storage.item-note-types.item.post'                 |
      | 'inventory-storage.ill-policies.item.post'                    |
      | 'inventory-storage.holdings-sources.item.post'                |
      | 'inventory-storage.holdings.collection.get'                   |
      | 'inventory-storage.holdings-sources.item.get'                 |
      | 'inventory-storage.instances.item.post'                       |
      | 'inventory-storage.holdings.item.post'                        |
      | 'inventory-storage.items.item.post'                           |
      | 'inventory-storage.identifier-types.collection.get'           |
      | 'inventory.items.collection.get'                              |
      | 'inventory.items.item.get'                                    |
      | 'configuration.entries.item.post'                             |
      | 'organizations-storage.organizations.item.post'               |
      | 'source-storage.source-records.collection.get'                |
      | 'source-storage.source-records.item.get'                      |
      | 'source-storage.records.formatted.item.get'                   |
      | 'source-storage.records.item.get'                             |
      | 'data-export.file-definitions.item.post'                      |
      | 'data-export.file-definitions.upload.post'                    |
      | 'data-export.file-definitions.item.get'                       |
      | 'data-export.export.post'                                     |
      | 'data-export.job-executions.collection.get'                   |
      | 'data-export.job-executions.items.download.get'               |
      | 'data-export.job-profiles.item.post'                          |
      | 'data-export.mapping-profiles.item.post'                      |
      | 'data-export.quick.export.post'                               |
      | 'data-import.assembleStorageFile.post'                        |
      | 'data-import.splitconfig.get'                                 |
      | 'data-import.uploaddefinitions.post'                          |
      | 'data-import.uploadDefinitions.item.get'                      |
      | 'data-import.upload.file.post'                                |
      | 'data-import.uploadDefinitions.files.item.post'               |
      | 'data-import.uploadDefinitions.processFiles.item.post'        |
      | 'data-import.fileExtensions.item.get'                         |
      | 'data-import.fileExtensions.collection.get'                   |
      | 'data-import.fileExtensions.post'                             |
      | 'data-import.fileExtensions.put'                              |
      | 'data-import.fileExtensions.delete'                           |
      | 'data-import.fileExtensions.default.post'                     |
      | 'data-import.uploadUrl.item.get'                              |
      | 'converter-storage.jobprofile.item.get'                       |
      | 'converter-storage.jobprofile.post'                           |
      | 'converter-storage.jobprofile.delete'                         |
      | 'converter-storage.actionprofile.post'                        |
      | 'converter-storage.actionprofile.delete'                      |
      | 'converter-storage.mappingprofile.post'                       |
      | 'converter-storage.mappingprofile.delete'                     |
      | 'change-manager.jobExecutions.item.get'                       |
      | 'change-manager.jobExecutions.children.collection.get'        |
      | 'change-manager.jobexecutions.delete'                         |
      | 'metadata-provider.jobLogEntries.collection.get'              |
      | 'metadata-provider.jobLogEntries.records.item.get'            |
      | 'converter-storage.matchprofile.post'                         |
      | 'mapping-rules.get'                                           |
      | 'mapping-rules.update'                                        |
      | 'mapping-metadata.item.get'                                   |
      | 'mapping-metadata.type.item.get'                              |
      | 'invoice-storage.invoice-lines.collection.get'                |
      | 'invoice-storage.invoices.item.get'                           |
      | 'orders.item.post'                                            |
      | 'orders.item.get'                                             |
      | 'orders.item.put'                                             |
      | 'orders.po-lines.item.post'                                   |
      | 'orders.po-lines.item.get'                                    |
      | 'acquisitions-units-storage.memberships.item.post'            |
      | 'acquisitions-units-storage.units.item.post'                  |
      | 'copycat.imports.post'                                        |
      | 'copycat.profiles.item.put'                                   |
      | 'metadata-provider.jobExecutions.collection.get'              |
      | 'inventory-storage.authorities.item.get'                      |
      | 'converter-storage.actionprofile.collection.get'              |
      | 'marc-records-editor.item.get'                                |
      | 'mapping-rules.restore'                                       |
      | 'inventory-storage.items.collection.get'                      |
      | 'data-import.uploaddefinitions.files.delete'                  |
      | 'data-import.datatypes.get'                                   |
      | 'data-import.uploadUrl.subsequent.item.get'                   |
      | 'data-import.downloadUrl.get'                                 |
      | 'data-import.jobexecution.cancel'                             |
      | 'metadata-provider.journalRecords.collection.get'             |
      | 'invoice-storage.invoice-lines.item.get'                      |
      | 'orders-storage.titles.item.get'                              |
      | 'metadata-provider.jobExecutions.users.collection.get'        |
      | 'organizations.organizations.collection.get'                  |
      | 'copycat.profiles.collection.get'                             |
      | 'invoice.invoice-lines.collection.get'                        |
      | 'invoice.invoice-lines.fund-distributions.validate'           |
      | 'invoice.invoice-lines.item.post'                             |
      | 'invoice.invoice-lines.item.delete'                           |
      | 'invoice.invoice-lines.item.put'                              |
      | 'invoice.invoice-lines.item.get'                              |
      | 'invoice.invoice-number.item.get'                             |
      | 'invoice.invoices.collection.get'                             |
      | 'invoice.invoices.documents.collection.get'                   |
      | 'invoice.invoices.documents.item.post'                        |
      | 'invoice.invoices.documents.item.delete'                      |
      | 'invoice.invoices.documents.item.get'                         |
      | 'invoice.invoices.fiscal-years.collection.get'                |
      | 'invoice.invoices.item.post'                                  |
      | 'invoice.invoices.item.delete'                                |
      | 'invoice.invoices.item.put'                                   |
      | 'invoice.invoices.item.get'                                   |
      | 'invoice.item.approve.execute'                                |
      | 'invoice.item.cancel.execute'                                 |
      | 'invoice.item.pay.execute'                                    |
      | 'invoices.acquisitions-units-assignments.assign'              |
      | 'invoices.acquisitions-units-assignments.manage'              |


  Scenario: create tenant and users for testing
    * call read('classpath:common/eureka/setup-users.feature')
    * eval java.lang.System.setProperty('testUserId', karate.get('userId'))

  Scenario: init global data
    * call login testUser

    * callonce read('classpath:folijet/data-import/global/mod_inventory_init_data.feature')
    * callonce read('classpath:folijet/data-import/global/init-acquisition-data.feature')
