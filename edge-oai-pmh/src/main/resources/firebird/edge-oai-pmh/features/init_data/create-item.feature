Feature: create item

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapiTokenAdmin = okapitoken

  Scenario: Create item

    Given path 'item-storage/items'
    And header Accept = 'application/json'
    And header x-okapi-token = okapiTokenAdmin
    * def item = read('classpath:samples/item.json')
    * set item.holdingsRecordId = holdingId
    * set item.id = itemId
    * set item.hrid = itemHrid
    * set item.barcode = barcode
    And request item
    When method POST
    Then status 201