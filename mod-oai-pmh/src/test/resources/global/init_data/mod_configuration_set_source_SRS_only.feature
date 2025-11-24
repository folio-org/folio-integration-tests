Feature: init data for mod-configuration - Source record storage only

  Background:
    * url baseUrl

  Scenario: Configure OAI-PMH for Source record storage only
    Given path '/oai-pmh/configuration-settings'
    And param query = 'name==behavior'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    When method GET
    Then status 200

    * def configId = get response.configurationSettings[0].id

    Given path '/oai-pmh/configuration-settings', configId
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    And request
    """
    {
      "configName": "behavior",
      "configValue": {
        "deletedRecordsSupport": "persistent",
        "suppressedRecordsProcessing": "true",
        "errorsProcessing": "500",
        "recordsSource": "Source record storage"
      }
    }

    """
    When method PUT
    Then status 200

