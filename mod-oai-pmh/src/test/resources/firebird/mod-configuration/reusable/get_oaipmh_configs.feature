Feature: get OAIPMH configs

  Background:
    * url baseUrl

  Scenario: get oai-pmh configuration
    Given path 'configurations/entries'
    And param query = 'module==OAIPMH'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-tenant = testUser.tenant
    And header x-okapi-token = testUserToken
    When method GET
    Then status 200

