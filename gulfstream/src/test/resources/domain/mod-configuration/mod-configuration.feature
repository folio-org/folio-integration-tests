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

    * def testTenant = 'test_oaipmh' +  runId
    * def testAdmin = {tenant: '#(testTenant)', name: 'test-admin', password: 'admin'}
    * def testUser = {tenant: '#(testTenant)', name: 'test-user', password: 'test'}
    * set testUser.tenant = testTenant
    * print '***test tenant = ', testUser.tenant


  Scenario: add okapi permissions to admin user
    Given call read('classpath:global/add-okapi-permissions.feature')

  Scenario: create tenant and users for testing
    Given call read('classpath:common/setup-users.feature')

  #============================FEATURES==========================================

  Scenario: oai-pmh basic tests
    Given call read('features/init-default-configuration.feature')

#  #==============================================================================
  Scenario: wipe data
    Given call read('classpath:common/destroy-data.feature')
