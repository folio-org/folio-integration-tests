Feature: Test enhancements to oai-pmh

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
    #=========================SETUP================================================
    * callonce login testUser
    * callonce read('classpath:global/init_data/mod_configuration_init_data.feature')
    * callonce read('classpath:global/init_data/mod_inventory_init_data.feature')
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
