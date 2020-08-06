Feature: post instance, holdings and items

  Background:
    * url baseUrl

  Scenario:
    Given path 'instance-storage/instances'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def instance = read('classpath:samples/instance.json')
    * set instance.id = instanceId
    * set instance.hrid = hridId
    And request instance
    When method POST
    Then status 201

    Given path 'holdings-storage/holdings'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def holding = read('classpath:samples/holding.json')
    * set holding.id = holdingId
    * set holding.instanceId = instanceId
    * set holding.hrid = hridId
    And request holding
    When method POST
    Then status 201

    Given path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = testUserToken
    * def item = read('classpath:samples/item.json')
    * set item.id = itemId
    * set item.holdingsRecordId = holdingId
    * set item.hrid = hridId
    And request item
    When method POST
    Then status 201
