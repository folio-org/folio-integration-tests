Feature: mod-oai-pmh tests

  Background:
    * url baseUrl

    * table modules
      | name                              |
      | 'mod-permissions'                 |
      | 'mod-oai-pmh'                     |
      | 'mod-login'                       |
      | 'mod-configuration'               |

    * table adminAdditionalPermissions
      | name|

    * table userPermissions
      | name                              |
      | 'oai-pmh.all'                     |
      | 'configuration.all'               |

    * def testTenant = 'test_oaipmh' + runId
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}
    * set testUser.tenant = testTenant
    * print '***test tenant = ', testUser.tenant


  Scenario: add okapi permissions to admin user
    Given call read('classpath:global/add-okapi-permissions.feature')

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  Scenario: setup test data
    * call login testAdmin
    * callonce read('classpath:global/init_data/srs_init_data.feature')
    * callonce read('classpath:global/init_data/mod_configuration_init_data.feature')
    * callonce read('classpath:global/init_data/mod_inventory_init_data.feature')

  #============================FEATURES==========================================


  # When tenant is deleted, there is an issue in mod-permissions that prevents enabling modules in future for the same tenant name:
  # POST request for mod-permissions-5.12.0-SNAPSHOT.86 /_/tenantpermissions failed with 400: function count_estimate(unknown) does not exist
  #
  # In edge, tenant is inside APIKEY and to solve the issue we use random tenant name. Hence these tests are for mod-oai-pmh, not edge


  Scenario: oai-pmh basic tests
    Given call read('features/oaipmh-basic.feature')


  #==============================================================================
  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')

