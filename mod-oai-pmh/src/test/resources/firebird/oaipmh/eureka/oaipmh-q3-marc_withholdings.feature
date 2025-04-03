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
#    * call destroyData {tenant: 'oaipmhtesttenant1482'}
    * configure afterFeature =  function(){ karate.call('classpath:common/destroy-data.feature', {tenant: testUser.tenant})}
    #=========================SETUP================================================
    Given call read('classpath:common/setup-users.feature')
    * callonce read('classpath:common/login.feature') testUser
    * callonce read('classpath:global/init_data/mod_configuration_init_data.feature')
    * callonce read('classpath:global/init_data/mod_inventory_init_data.feature')
    #=========================SETUP=================================================
    * callonce resetConfiguration
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }

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
