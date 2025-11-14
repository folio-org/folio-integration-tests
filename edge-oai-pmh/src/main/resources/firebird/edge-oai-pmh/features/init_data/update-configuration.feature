Feature: update configuration

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapiTokenAdmin = okapitoken

  @TechnicalConfig
  Scenario: set technical config
    Given path 'oai-pmh/configuration-settings'
      And param name='technical'
      And header Accept = 'application/json'
      And header Content-Type = 'application/json'
      And header x-okapi-token = okapiTokenAdmin
      And header x-okapi-tenant = testTenant
      When method GET
      Then status 200

    * def configId = response.configurationSettings[0].id

    Given path 'oai-pmh/configuration-settings', configId
    And request
    """
    {
      "id" : configId,
      "configName" : "technical",
      "configValue" : {
        "maxRecordsPerResponse" : "1",
        "enableValidation" : "false",
        "formattedOutput" : "false"
      }
    }
    """
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method PUT
    Then status 204

  @BehaviorConfig
  Scenario: set behavior config
    Given path 'oai-pmh/configuration-settings'
    And param name = 'behavior'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200

    * def configId = response.configurationSettings[0].id

    Given path 'oai-pmh/configuration-settings', configId
    And request
    """
    {
      "id" : configId,
      "configName" : "behavior",
      "configValue" : {
        "deletedRecordsSupport" : "persistent",
        "suppressedRecordsProcessing" : "true",
        "recordsSource" : "Source record storage",
        "errorsProcessing": "200"
      }
    }
    """
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method PUT
    Then status 204