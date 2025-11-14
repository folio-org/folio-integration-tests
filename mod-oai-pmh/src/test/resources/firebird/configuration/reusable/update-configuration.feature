Feature: Reset default OAIPMH configs

  Background:
    * url baseUrl + '/oai-pmh/configuration-settings'

  @BehaviorConfig
  Scenario: set behavior config
    * copy template = behaviorTemplate
    * set template.id = id
    * set template.configValue = data
    Given path id
    And request template
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    When method PUT
    Then status 200

  @TechnicalConfig
  Scenario: set technical config
    * copy template = technicalTemplate
    * set template.id = id
    * set template.configValue = data
    Given path id
    And request template
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    When method PUT
    Then status 200

  @GeneralConfig
  Scenario: set general config
    * copy template = generalTemplate
    * set template.id = id
    * set template.configValue = data
    Given path id
    And request template
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    When method PUT
    Then status 200

  @SetErrorProcessing500
  Scenario: Set error processing setting to 500
    * def errorsProcessingConfig = '500'
    * call read('classpath:firebird/mod-configuration/reusable/config-templates.feature')
    * call read('classpath:firebird/mod-configuration/reusable/update-configuration.feature@BehaviorConfig') {id: '#(behaviorId)', data: '#(behaviorValue)'}


