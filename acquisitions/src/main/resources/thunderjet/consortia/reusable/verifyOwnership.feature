@ignore
Feature: Verify that Holding and Item are updated with the new ownership

  Background:
    * url baseUrl

  Scenario: verifyOwnership
    Given path 'holdings-storage/holdings'
    And param query = 'instanceId==' + instanceId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.holdingsRecords[*].id contains holdingId
    And match response.holdingsRecords[*].instanceId contains instanceId
    And match response.holdingsRecords[*].permanentLocationId contains locationId
    And def sharedHoldingId = response.holdingsRecords[0].id

    Given path 'inventory/items-by-holdings-id'
    And param query = 'holdingsRecordId==' + sharedHoldingId
    When method GET
    Then status 200
    And match response.totalRecords == 1
    And match response.items[*].id contains itemId
    And match response.items[*].holdingsRecordId contains sharedHoldingId
