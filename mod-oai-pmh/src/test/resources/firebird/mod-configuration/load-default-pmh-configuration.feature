Feature: Test integration with mod-configuration during Posting the mod-oai-pmh module for tenant

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }
    #=========================SETUP=================================================

    * def result = call getModuleIdByName {tenant: #(testUser.tenant), moduleName: mod-oai-pmh}
    * def moduleId = result.response[0].id
    * def module = {tenant: #(testUser.tenant), moduleId: #(moduleId)}

  Scenario: Should post default configs to mod-configuration and enable the module when mod-config does not contain the data
    * def result = call read('classpath:firebird/mod-configuration/reusable/get_oaipmh_configs.feature')
    * def configResponse = result.response

    Given path '/oai-pmh/configuration-settings'
    And header Content-Type = 'application/json'
    And header Accept = '*/*'
    And header x-okapi-tenant = testUser.tenant
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    And match response.configurationSettings[*].configName contains 'behavior'
    And match response.configurationSettings[*].configName contains 'technical'
    And match response.configurationSettings[*].configName contains 'general'

  Scenario: Should just enable module when mod-configuration already contains all related configs
    * def result = call read('classpath:firebird/mod-configuration/reusable/get_oaipmh_configs.feature')
    * def configResponse = result.response
    * def configGroups = get configResponse.configurationSettings[*].configName
    * print response
    And match configGroups contains 'behavior'
    And match configGroups contains 'technical'
    And match configGroups contains 'general'

    Given path '/oai-pmh/configuration-settings'
    And header Content-Type = 'application/json'
    And header Accept = '*/*'
    And header x-okapi-tenant = testUser.tenant
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    And match response.configurationSettings[*].configName contains 'behavior'
    And match response.configurationSettings[*].configName contains 'technical'
    And match response.configurationSettings[*].configName contains 'general'
