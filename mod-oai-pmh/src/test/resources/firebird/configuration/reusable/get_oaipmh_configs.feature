Feature: get OAIPMH configs

  Background:
    * url baseUrl

  Scenario: get oai-pmh configuration
    Given path 'oai-pmh/configuration-settings'
    And header Accept = 'application/json'
    And header Content-Type = 'application/json'
    And header x-okapi-tenant = testUser.tenant
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200

