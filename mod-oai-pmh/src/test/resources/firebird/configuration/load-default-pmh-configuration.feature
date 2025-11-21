@parallel=false
Feature: Test integration with mod-configuration during Posting the mod-oai-pmh module for tenant

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }
    #=========================SETUP=================================================

    * def result = call getModuleIdByName {tenant: #(testUser.tenant), moduleName: mod-oai-pmh}
    * def moduleId = result.response[0].id
    * def module = {tenant: #(testUser.tenant), moduleId: #(moduleId)}

  Scenario: Should post default configs to configuration and enable the module when config does not contain the data
    * def result = call read('classpath:firebird/configuration/reusable/get_oaipmh_configs.feature')
    * def configResponse = result.response

    Given path 'oai-pmh/configuration-settings'
    And header Content-Type = 'application/json'
    And header Accept = '*/*'
    And header x-okapi-tenant = testUser.tenant
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    * def configGroups = karate.map(configResponse.configurationSettings, function(x){ return x.configName })
    And match configGroups contains 'behavior'
    And match configGroups contains 'technical'
    And match configGroups contains 'general'

  Scenario: Should just enable module when configuration already contains all related configs
    * def result = call read('classpath:firebird/configuration/reusable/get_oaipmh_configs.feature')
    * def configResponse = result.response
    * def configGroups = get configResponse.configurationSettings[*].configName
    And match configGroups contains 'behavior'
    And match configGroups contains 'technical'
    And match configGroups contains 'general'

    Given path 'oai-pmh/configuration-settings'
    And header Content-Type = 'application/json'
    And header Accept = '*/*'
    And header x-okapi-tenant = testUser.tenant
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    * def configGroups = karate.map(configResponse.configurationSettings, function(x){ return x.configName })
    And match configGroups contains 'behavior'
    And match configGroups contains 'technical'
    And match configGroups contains 'general'
