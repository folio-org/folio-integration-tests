Feature: mod-data-import integration tests

  Background:
    * url baseUrl
    * table modules
      | name                          |
      | 'mod-login'                   |
      | 'mod-permissions'             |
      | 'mod-data-import'             |
      | 'mod-source-record-storage'   |
      | 'mod-source-record-manager'   |

    * def testTenant = 'test_data_import' + runId

    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table adminAdditionalPermissions
      | name |

    * table userPermissions
      | name                 |
      | 'data-import.all' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: test dataImport
    Given call read('scenario/test-data-import.feature')

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
