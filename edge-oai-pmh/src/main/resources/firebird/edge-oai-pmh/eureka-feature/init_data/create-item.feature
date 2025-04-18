Feature: create item

  Background:
    * url baseUrl
    * callonce login testUser

  Scenario: Create item

    Given path 'item-storage/items'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And header x-okapi-tenant = testTenant
    * def item = read('classpath:samples/item.json')
    * set item.holdingsRecordId = holdingId
    * set item.id = itemId
    * set item.hrid = itemHrid
    * set item.barcode = barcode
    And request item
    When method POST
    Then status 201