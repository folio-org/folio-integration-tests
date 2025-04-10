Feature: create holding

  Background:
    * url baseUrl
    * callonce login testUser

  Scenario: create holding for instance
    Given path 'holdings-storage/holdings'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def holding = read('classpath:samples/holding.json')
    * set holding.id = holdingId
    * set holding.instanceId = instanceId
    * set holding.hrid = holdingHrid
    * set holding.permanentLocationId = permanentLocationId
    And request holding
    When method POST
    Then status 201