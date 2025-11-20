Feature: Test integration with mod-oai-pmh configuration settings during Posting the mod-oai-pmh module for tenant

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }
    #=========================SETUP=================================================

    * def result = call getModuleIdByName {tenant: #(testUser.tenant), moduleName: mod-oai-pmh}
    * def moduleId = result.response[0].id
    * def module = {tenant: #(testUser.tenant), moduleId: #(moduleId)}

  Scenario: Should post default configs to oai-pmh configuration-settings and enable the module when config does not contain the data
    * def result = call read('classpath:firebird/mod-configuration/reusable/get_oaipmh_configs.feature')
    * def configResponse = result.response

    Given path '/oai-pmh/configuration-settings'
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

  Scenario: Should just enable module when oai-pmh configuration-settings already contains all related configs
    * def result = call read('classpath:firebird/mod-configuration/reusable/get_oaipmh_configs.feature')
    * def configResponse = result.response
    * def configGroups = get configResponse.configs[*].configName
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
    * def configGroups = karate.filter(configResponse.configs, function(x){ return x.module == 'OAIPMH' })
    * def configGroups = karate.map(configGroups, function(x){ return x.configName })
    And match configGroups contains 'behavior'
    And match configGroups contains 'technical'
    And match configGroups contains 'general'

Feature: Reset default OAIPMH configs

  Background:
    * url baseUrl + '/oai-pmh/configuration-settings'

  @BehaviorConfig
  Scenario: set behavior config
    * copy template = behaviorTemplate
    * set template.value = data
    Given path id
    And request template
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    When method PUT
    Then status 204

  @TechnicalConfig
  Scenario: set technical config
    * copy template = technicalTemplate
    * set template.value = data
    Given path id
    And request template
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    When method PUT
    Then status 204

  @GeneralConfig
  Scenario: set general config
    * copy template = generalTemplate
    * set template.value = data
    Given path id
    And request template
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    When method PUT
    Then status 204

  @SetErrorProcessing500
  Scenario: Set error processing setting to 500
    * def errorsProcessingConfig = '500'
    * call read('classpath:firebird/mod-configuration/reusable/mod-config-templates.feature')
    * copy valueTemplate = behaviorValue
    * string valueTemplateString = valueTemplate
    * call read('classpath:firebird/mod-configuration/reusable/update-configuration.feature@BehaviorConfig') {id: '#(behaviorId)', data: '#(valueTemplateString)'}



