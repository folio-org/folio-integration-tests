Feature: delete config

  Background:
    * url baseUrl

  Scenario: deletes oai-pmh config by id
    Given path '/oai-pmh/configuration-settings', id
    And header Accept = '*/*'
    And header Content-Type = 'application/json'
    And header x-okapi-tenant = testTenant
    And header x-okapi-token = karate.properties['okapitoken']
    When method DELETE
    Then status 204

