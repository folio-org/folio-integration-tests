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
    Then status 200

    * def configId = get response.configs[0].id

    Given path 'oai-pmh/configuration-settings', configId
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
       "value" : "{\"deletedRecordsSupport\":\"no\",\"suppressedRecordsProcessing\":\"false\",\"errorsProcessing\":\"500\"}"
    }
    """
    When method PUT
    Then status 204
