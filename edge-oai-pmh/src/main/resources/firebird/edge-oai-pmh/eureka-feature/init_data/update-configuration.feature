Feature: update configuration

  Background:
    * url baseUrl
    * callonce login testUser

  @TechnicalConfig
  Scenario: set technical config
    Given path 'configurations/entries'
    And param query = 'module==OAIPMH and configName==technical'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200

    * def configId = response.configs[0].id

    Given path 'configurations/entries', configId
    And request
      """
      {
        "module" : "OAIPMH",
        "configName" : "technical",
        "enabled" : true,
        "value" : "{\"maxRecordsPerResponse\":\"1\",\"enableValidation\":\"false\",\"formattedOutput\":\"false\"}"
      }
      """
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method PUT
    Then status 204

  @BehaviorConfig
  Scenario: set behavior config
    Given path 'configurations/entries'
    And param query = 'module==OAIPMH and configName==behavior'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200

    * def configId = response.configs[0].id

    Given path 'configurations/entries', configId
    And request
      """
      {
        "module" : "OAIPMH",
        "configName" : "behavior",
        "enabled" : true,
        "value" : "{\"suppressedRecordsProcessing\":\"true\",\"recordsSource\":\"Source record storage\",\"deletedRecordsSupport\":\"persistent\",\"errorsProcessing\":\"200\"}"
      }
      """
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    When method PUT
    Then status 204