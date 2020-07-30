Feature: delete config

  Background:
    * url baseUrl

  Scenario: deletes oai-pmh config by id
    Given path 'configurations/entries', id
    And header Accept = '*/*'
    And header Content-Type = 'application/json'
    And header x-okapi-tenant = testTenant
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

