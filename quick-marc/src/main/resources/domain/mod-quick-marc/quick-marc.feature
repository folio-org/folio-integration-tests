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

    * def testTenant = 'test_quick_marc' + runId

    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name                 |
      | 'records-editor.all' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: test quickMARC
    Given call read('features/test-quick-marc.feature')

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
