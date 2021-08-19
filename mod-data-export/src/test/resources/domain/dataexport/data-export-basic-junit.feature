Feature: mod-orders integration tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-data-export'           |
      | 'mod-login'                 |
      | 'mod-configuration'         |
      | 'mod-source-record-storage' |
      | 'mod-inventory-storage'     |

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name                    |
      | 'data-export.all'       |
      | 'configuration.all'     |
      | 'inventory-storage.all' |
      | 'source-storage.all'    |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:global/mod_inventory_init_data.feature')
    * callonce read('classpath:global/mod_data_export_init_data.feature')
