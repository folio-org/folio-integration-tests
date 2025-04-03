Feature: Test enhancements to oai-pmh

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl
#    * call destroyData {tenant: 'oaipmhtesttenant1482'}
    #=========================SETUP================================================
    * callonce login testUser
#    TODO: refactor these global features into setup-data.feature or in before all method
    * callonce read('classpath:global/eureka/init_data/mod_configuration_init_data.feature')
    * callonce read('classpath:global/eureka/init_data/mod_inventory_init_data.feature')
    #=========================SETUP=================================================
    * callonce resetConfigurationEureka
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