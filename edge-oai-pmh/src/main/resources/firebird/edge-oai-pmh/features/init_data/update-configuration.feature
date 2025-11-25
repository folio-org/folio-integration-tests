Feature: update configuration

  Background:
    * url baseUrl
    * callonce login testUser
    * def okapiTokenAdmin = okapitoken

  @BehaviorConfig
  Scenario: set behavior config
    Given path '/oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method GET
    Then status 200

    * def configId = response.configurationSettings[0].id

    Given path '/oai-pmh/configuration-settings', configId
    And request
      """
      {
        "configName": "behavior",
        "configValue": {
          "suppressedRecordsProcessing": "true",
          "recordsSource": "Source record storage",
          "deletedRecordsSupport": "persistent",
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

  @TechnicalConfig
  Scenario: set technical config
    Given path '/oai-pmh/configuration-settings'
      And param query = 'name==technical'
      And header Accept = 'application/json'
      And header Content-Type = 'application/json'
      And header x-okapi-token = okapiTokenAdmin
      And header x-okapi-tenant = testTenant
      When method GET
      Then status 200

    * def configId = response.configurationSettings[0].id

    Given path '/oai-pmh/configuration-settings', configId
    And request
    """
    {
      "configName": "technical",
      "configValue": {
        "maxRecordsPerResponse": "1",
        "enableValidation": "false",
        "formattedOutput": "false"
      }
    }

    """
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And header x-okapi-tenant = testTenant
    When method PUT
    Then status 204
