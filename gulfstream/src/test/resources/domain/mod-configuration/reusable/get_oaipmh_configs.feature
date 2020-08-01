Feature: get OAIPMH configs

  Background:
    * url baseUrl
    * callonce login testUser

  Scenario: get oai-pmh configuration
    Given path 'configurations/entries'
    And param query = 'module==OAIPMH'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-tenant = testTenant
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200

