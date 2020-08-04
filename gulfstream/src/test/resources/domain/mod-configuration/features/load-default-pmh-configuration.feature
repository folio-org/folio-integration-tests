Feature: Test integration with mod-configuration during Posting the mod-oai-pmh module for tenant

  Background:
    * url baseUrl
    * def result = call getModuleIdByName {tenant: #(testTenant), moduleName: mod-oai-pmh}
    * def moduleId = result.response[0].id
    * def module = {tenant: #(testTenant), moduleId: #(moduleId)}

  Scenario: Should post default configs to mod-configuration and enable the module when mod-config does not contain the data
    * def result = call read('classpath:domain/mod-configuration/reusable/get_oaipmh_configs.feature')
    * def configResponse = result.response
    * def ids = get configResponse.configs[*].id
    * def configIds = karate.mapWithKey(ids, 'id')

    Given call deleteModule $module
    Given call read('classpath:domain/mod-configuration/reusable/delete_config_by_id.feature') configIds
    Given call enableModule $module
    Given path '/configurations/entries'
    And header Content-Type = 'application/json'
    And header Accept = '*/*'
    And header x-okapi-tenant = testTenant
    And header x-okapi-token = karate.properties['testUserToken']
    When method GET
    Then status 200
    * def configGroups = get $.configs[*].configName
    And match configGroups contains 'behavior'
    And match configGroups contains 'technical'
    And match configGroups contains 'general'

  Scenario: Should post missing default configs to mod-configuration and enable module when mod-config has only part of oaipmh configuration groups
    * def result = call read('classpath:domain/mod-configuration/reusable/get_oaipmh_configs.feature')
    * def configResponse = result.response
    * def ids = get configResponse.configs[*].id
    * def configIds = karate.mapWithKey(ids, 'id')

    Given call deleteModule $module
    Given call read('classpath:domain/mod-configuration/reusable/delete_config_by_id.feature') configIds
    Given path '/configurations/entries'
    And header Content-Type = 'application/json'
    And header Accept = '*/*'
    And header x-okapi-tenant = testTenant
    And header x-okapi-token = karate.properties['testUserToken']
    And request
    """
    {
      "module" : "OAIPMH",
      "configName" : "technical",
      "enabled" : true,
      "value" : "{\"maxRecordsPerResponse\":\"50\",\"enableValidation\":\"false\",\"formattedOutput\":\"false\"}"
    }
    """
    When method POST
    Then status 201

    Given call enableModule $module
    Given path '/configurations/entries'
    And header Content-Type = 'application/json'
    And header Accept = '*/*'
    And header x-okapi-tenant = testTenant
    And header x-okapi-token = karate.properties['testUserToken']
    When method GET
    Then status 200
    * def configGroups = get $.configs[*].configName
    And match configGroups contains 'behavior'
    And match configGroups contains 'technical'
    And match configGroups contains 'general'

  Scenario: Should just enable module when mod-configuration already contains all related configs
    * def result = call read('classpath:domain/mod-configuration/reusable/get_oaipmh_configs.feature')
    * def configResponse = result.response
    * def configGroups = get configResponse.configs[*].configName
    And match configGroups contains 'behavior'
    And match configGroups contains 'technical'
    And match configGroups contains 'general'

    Given call deleteModule $module
    Given call enableModule $module
    Given path '/configurations/entries'
    And header Content-Type = 'application/json'
    And header Accept = '*/*'
    And header x-okapi-tenant = testTenant
    And header x-okapi-token = karate.properties['testUserToken']
    When method GET
    Then status 200
    * def configGroups = get $.configs[*].configName
    And match configGroups contains 'behavior'
    And match configGroups contains 'technical'
    And match configGroups contains 'general'
