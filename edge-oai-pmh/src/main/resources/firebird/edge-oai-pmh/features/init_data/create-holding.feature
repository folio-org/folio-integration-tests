Feature: create holding

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapiTokenAdmin = okapitoken
    * def holdingsSource = read('classpath:samples/holdings_source.json');

  Scenario: create holdings records source if not exists
    Given path 'holdings-sources'
    And header Accept = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    And request holdingsSource
    When method POST
    Then status 201

  Scenario: create holding for instance
    Given path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    * def holding = read('classpath:samples/holding.json')
    * set holding.id = holdingId
    * set holding.instanceId = instanceId
    * set holding.hrid = holdingHrid
    * set holding.permanentLocationId = permanentLocationId
    And request holding
    When method POST
    Then status 201