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

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name                                       |
      | 'configuration.all'                        |
      | 'inventory-storage.all'                    |
      | 'source-storage.all'                       |
      | 'data-import.uploaddefinitions.post'       |
      | 'data-import.upload.file.post'             |
      | 'data-import.uploaddefinitions.get'        |
      | 'converter-storage.jobprofile.get'         |
      | 'converter-storage.jobprofile.post'        |
      | 'converter-storage.jobprofile.delete'      |
      | 'converter-storage.actionprofile.post'     |
      | 'converter-storage.actionprofile.delete'   |
      | 'converter-storage.mappingprofile.post'    |
      | 'converter-storage.mappingprofile.delete'  |
      | 'data-import.uploaddefinitions.files.post' |
      | 'data-import.fileExtensions.post'|
      | 'data-import.fileExtensions.get'           |
      | 'data-import.fileExtensions.put'           |
      | 'data-import.fileExtensions.delete'        |
      | 'data-import.fileExtensions.default'       |
      | 'change-manager.jobexecutions.get'  |
      | 'inventory.all'  |
      | 'metadata-provider.logs.get'  |


  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:domain/data-import/global/mod_inventory_init_data.feature')
