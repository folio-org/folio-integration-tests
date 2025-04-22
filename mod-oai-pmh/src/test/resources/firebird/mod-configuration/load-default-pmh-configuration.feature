Feature: Test integration with mod-configuration during Posting the mod-oai-pmh module for tenant

  Background:
    * url baseUrl
    * callonce login testUser
    * callonce read('classpath:global/setup-data.feature')
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }
    #=========================SETUP=================================================

    * def result = call getModuleIdByName {tenant: #(testUser.tenant), moduleName: mod-oai-pmh}
    * def moduleId = result.response[0].id
    * def module = {tenant: #(testUser.tenant), moduleId: #(moduleId)}

  Scenario: Should post default configs to mod-configuration and enable the module when mod-config does not contain the data
    * def result = call read('classpath:firebird/mod-configuration/reusable/get_oaipmh_configs.feature')
    * def configResponse = result.response

    Given path '/configurations/entries'
    And header Content-Type = 'application/json'
    And header Accept = '*/*'
    And header x-okapi-tenant = testUser.tenant
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    * def configGroups = karate.filter(configResponse.configs, function(x){ return x.module == 'OAIPMH' })
    * def configGroups = karate.map(configGroups, function(x){ return x.configName })
    And match configGroups contains 'behavior'
    And match configGroups contains 'technical'
    And match configGroups contains 'general'

  Scenario: Should just enable module when mod-configuration already contains all related configs
    * def result = call read('classpath:firebird/mod-configuration/reusable/get_oaipmh_configs.feature')
    * def configResponse = result.response
    * def configGroups = get configResponse.configs[*].configName
    And match configGroups contains 'behavior'
    And match configGroups contains 'technical'
    And match configGroups contains 'general'

    Given path '/configurations/entries'
    And header Content-Type = 'application/json'
    And header Accept = '*/*'
    And header x-okapi-tenant = testUser.tenant
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    * def configGroups = karate.filter(configResponse.configs, function(x){ return x.module == 'OAIPMH' })
    * def configGroups = karate.map(configGroups, function(x){ return x.configName })
    And match configGroups contains 'behavior'
    And match configGroups contains 'technical'
    And match configGroups contains 'general'
