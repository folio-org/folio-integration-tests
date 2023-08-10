Feature: init data for mod-configuration

  Background:
    * url baseUrl

  Scenario: set errors to 500 Http status
    Given path 'configurations/entries'
    And param query = 'module==OAIPMH and configName==behavior'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = testUserToken
    When method GET
    Then status 200

    * def configId = get response.configs[0].id

    Given path 'configurations/entries', configId
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-token = testUserToken
    And request
    """
    {
       "module" : "OAIPMH",
       "configName" : "behavior",
       "enabled" : true,
       "value" : "{\"deletedRecordsSupport\":\"persistent\",\"suppressedRecordsProcessing\":\"true\",\"errorsProcessing\":\"500\"}"
    }
    """
    When method PUT
    Then status 204
