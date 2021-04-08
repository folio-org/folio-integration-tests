Feature: mod-quick-marc integration tests

  Background:
    * url baseUrl
    * table modules
      | name                                |
      | 'mod-login'                         |
      | 'mod-permissions'                   |
      | 'mod-inventory-storage'             |
      | 'mod-inventory'                     |
      | 'mod-source-record-storage'         |
      | 'mod-source-record-manager'         |
      | 'mod-data-import'                   |
      | 'mod-data-import-converter-storage' |
      | 'mod-quick-marc'                    |

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name                 |
      | 'records-editor.all' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')
