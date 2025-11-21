Feature: init data for mod-configuration

  Background:
    * url baseUrl

  Scenario: set errors to 500 Http status
    Given path 'oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    When method GET
    * print response
    Then status 200

    * def configId = get response.configurationSettings[0].id
    * print 'Config ID: ' + configId

    Given path 'oai-pmh/configuration-settings', configId
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    And request
    """
    {
      "configName": "behavior",
      "configValue": {
        "suppressedRecordsProcessing": "false",
        "errorsProcessing": "500",
        "deletedRecordsSupport": "no"
      }
    }

    """
    When method PUT
    Then status 200
