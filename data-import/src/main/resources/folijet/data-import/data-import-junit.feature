Feature: mod-data-import integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-configuration'                 |
      | 'mod-data-import'                   |
      | 'mod-source-record-storage'         |
      | 'mod-source-record-manager'         |
      | 'mod-inventory-storage'             |
      | 'mod-data-import-converter-storage' |
      | 'mod-inventory'                     |
      | 'mod-data-export'                   |
      | 'mod-organizations-storage'         |
      | 'mod-invoice'                       |
      | 'mod-invoice-storage'               |
      | 'mod-copycat'                       |

    * table userPermissions
      | name                                           |
      | 'configuration.all'                            |
      | 'inventory-storage.all'                        |
      | 'source-storage.all'                           |
      | 'data-import.uploaddefinitions.post'           |
      | 'data-import.upload.file.post'                 |
      | 'data-import.uploaddefinitions.get'            |
      | 'converter-storage.jobprofile.get'             |
      | 'converter-storage.jobprofile.post'            |
      | 'converter-storage.jobprofile.delete'          |
      | 'converter-storage.actionprofile.post'         |
      | 'converter-storage.actionprofile.delete'       |
      | 'converter-storage.mappingprofile.post'        |
      | 'converter-storage.mappingprofile.delete'      |
      | 'data-import.uploaddefinitions.files.post'     |
      | 'data-import.fileExtensions.post'              |
      | 'data-import.fileExtensions.get'               |
      | 'data-import.fileExtensions.put'               |
      | 'data-import.fileExtensions.delete'            |
      | 'data-import.fileExtensions.default'           |
      | 'change-manager.jobexecutions.get'             |
      | 'change-manager.jobexecutions.delete'             |
      | 'inventory.all'                                |
      | 'metadata-provider.logs.get'                   |
      | 'converter-storage.matchprofile.post'          |
      | 'data-export.all'                              |
      | 'invoice.all'                                  |
      | 'mapping-rules.update'                         |
      | 'invoice-storage.invoice-lines.collection.get' |
      | 'invoice-storage.invoice-lines.item.get'       |
      | 'invoice-storage.invoices.item.get'            |
      | 'organizations-storage.organizations.all' |
      | 'orders.all' |
      | 'acquisitions-units-storage.memberships.item.post' |
      | 'acquisitions-units-storage.units.item.post' |
      | 'copycat.profiles.collection.get' |
      | 'copycat.imports.post' |
      | 'copycat.profiles.item.put' |
      | 'metadata-provider.jobexecutions.get' |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:folijet/data-import/global/mod_inventory_init_data.feature')
    * callonce read('classpath:folijet/data-import/global/init-acquisition-data.feature')
