Feature: data export basic tests

  Background:
    * url baseUrl
    * table modules
      | name                        |
      | 'mod-permissions'           |
      | 'mod-data-export'           |
      | 'mod-login'                 |
      | 'mod-inventory-storage'     |

    * def randomNumber = callonce random
    * def testTenant = 'dataexporttesttenant' + randomNumber
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}

    * table userPermissions
      | name              |
      | 'data-export.all' |

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: init global data
    * call login testAdmin

    * callonce read('classpath:global/mod_inventory_init_data.feature')

  Scenario: Start quick-export tests
    Given call read('features/quick-export.feature')

  Scenario: Start delete jobExecution tests
    Given call read('features/delete-job-execution.feature')

  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
