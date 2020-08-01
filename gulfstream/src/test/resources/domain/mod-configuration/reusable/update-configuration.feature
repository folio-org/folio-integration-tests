Feature: Reset default OAIPMH configs

  Background:
    * url baseUrl + '/configurations/entries'
    * callonce login testUser

  @BehaviorConfig
  Scenario: set behavior config
    * copy template = behaviorTemplate
    * set template.value = data
    Given path id
    And request template
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
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
    When method PUT
    Then status 204


