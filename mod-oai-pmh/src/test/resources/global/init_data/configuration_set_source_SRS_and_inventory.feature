Feature: init data for mod-configuration

  Background:
    * url baseUrl

  Scenario: set errors to 500 Http status
    Given path 'oai-pmh/configuration-settings'
    And param name = 'behavior'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    When method GET
    Then status 200

    * def configId = get response.configurationSettings[0].id

    Given path 'oai-pmh/configuration-settings', configId
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    And request
    """
    {
      "id" : configId,
      "configName" : "behavior",
      "configValue" : {
        "deletedRecordsSupport" : "persistent",
        "suppressedRecordsProcessing" : "true",
        "errorsProcessing" : "500",
        "recordsSource" : "Source record storage and Inventory"
      }
    }
    """
    When method PUT
    Then status 200
