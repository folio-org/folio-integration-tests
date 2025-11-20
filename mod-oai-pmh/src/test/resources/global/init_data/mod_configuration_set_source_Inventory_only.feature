Feature: init data for mod-configuration - Inventory only

  Background:
    * url baseUrl

  Scenario: Configure OAI-PMH for Inventory only
    Given path 'configurations/entries'
    And param query = 'configName==behavior'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    When method GET
    Then status 200

    * def configId = get response.configs[0].id

    Given path 'configurations/entries', configId
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testUser.tenant
    And request
    """
    {
       "module" : "OAIPMH",
       "configName" : "behavior",
       "enabled" : true,
       "value" : "{\"deletedRecordsSupport\":\"persistent\",\"suppressedRecordsProcessing\":\"true\",\"errorsProcessing\":\"500\",\"recordsSource\":\"Inventory\"}"
    }
    """
    When method PUT
    Then status 204

