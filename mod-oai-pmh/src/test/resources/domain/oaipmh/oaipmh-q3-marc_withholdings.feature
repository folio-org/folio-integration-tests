Feature: Test enhancements to oai-pmh

  Background:
    * table modules
      | name                              |
      | 'mod-permissions'                 |
      | 'mod-oai-pmh'                     |
      | 'mod-login'                       |
      | 'mod-configuration'               |
      | 'mod-source-record-storage'       |

    * table userPermissions
      | name                              |
      | 'oai-pmh.all'                     |
      | 'configuration.all'               |
      | 'inventory-storage.all'           |
      | 'source-storage.all'              |

    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
#    * call destroyData {tenant: 'oaipmh_test_tenant1482'}
        * configure afterFeature =  function(){ karate.call(destroyData, {tenant: testUser.tenant})}
    #=========================SETUP================================================
    * callonce read('classpath:common/tenant.feature@create')
    * callonce read('classpath:common/tenant.feature@install') { modules: '#(modules)', tenant: '#(testUser.tenant)'}
    * callonce read('classpath:common/setup-users.feature')
    * callonce read('classpath:common/login.feature') testUser
    * def testUserToken = responseHeaders['x-okapi-token'][0]
    * callonce read('classpath:global/init_data/mod_configuration_init_data.feature')
    * callonce read('classpath:global/init_data/mod_inventory_init_data.feature')
    #=========================SETUP=================================================
    * callonce resetConfiguration
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(testUserToken)', 'x-okapi-tenant': '#(testUser.tenant)' }

  Scenario Outline: request instance records identifiers should query inventory for <prefix>
    And param verb = 'ListIdentifiers'
    And param metadataPrefix = <prefix>
    And header Accept = 'text/xml'
    When method GET
    Then status 200
    * match response count(//identifier) == 10

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |