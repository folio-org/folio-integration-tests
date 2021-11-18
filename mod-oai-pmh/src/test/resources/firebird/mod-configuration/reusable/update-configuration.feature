Feature: Reset default OAIPMH configs

  Background:
    * url baseUrl + '/configurations/entries'

  @BehaviorConfig
  Scenario: set behavior config
    * copy template = behaviorTemplate
    * set template.value = data
    Given path id
    And request template
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = testUserToken
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
    And header x-okapi-token = testUserToken
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
    And header x-okapi-token = testUserToken
    When method PUT
    Then status 204

  @SetErrorProcessing500
  Scenario: Set error processing setting to 500
    * def errorsProcessingConfig = '500'
    * call read('classpath:firebird/mod-configuration/reusable/mod-config-templates.feature')
    * copy valueTemplate = behaviorValue
    * string valueTemplateString = valueTemplate
    * call read('classpath:firebird/mod-configuration/reusable/update-configuration.feature@BehaviorConfig') {id: '#(behaviorId)', data: '#(valueTemplateString)'}


