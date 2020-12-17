Feature: data export basic tests
  #
  # Tests according to http://www.openarchives.org/Register/ValidateSite
  #
  Background:
    * url baseUrl
    * table modules
      | name                              |
      | 'mod-permissions'                 |
      | 'mod-data-export'                 |
      | 'mod-login'                       |
      | 'mod-configuration'               |
      | 'mod-source-record-storage'       |

    * table userPermissions
      | name                              |
      | 'data-export.all'                 |
      | 'configuration.all'               |
      | 'inventory-storage.all'           |
      | 'source-storage.all'              |

    * table adminAdditionalPermissions
      | name |

    * def testTenant = 'data_export_test_tenant'
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:global/mod_inventory_init_data.feature')

    Scenario: Start quick-export tests
    Given call read('features/quick-export.feature')

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
