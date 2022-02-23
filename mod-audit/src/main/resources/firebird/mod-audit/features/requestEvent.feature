Feature: mod audit data REQUEST event

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * callonce variables

  # Should be added new log record

  Scenario: Generate REQUEST_CREATED_EVENT and verify number of REQUEST records
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    * def num_records = $.totalRecords
    Given path 'circulation/requests'
    And request
    """
    {
    "id": "#(requestId)",
    "requesterId": "#(userid)",
    "itemId": "#(itemIdRequest)",
    "instanceId" : "#(instanceId)",
    "requestLevel" : "Item",
    "holdingsRecordId" : "#(holdingsRecordId)",
    "requestType": "Page",
    "fulfilmentPreference": "Hold Shelf",
    "pickupServicePointId": "#(servicePointId)",
    "requestDate": "#(checkInDate)"
    }
    """
    When method POST
    Then status 201
    And call pause 5000
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    And match $.totalRecords == num_records + 1
    * def lastAction = get[0] $.logRecords[-1:].action
    And match lastAction == 'Created'
    Given path 'circulation/requests', requestId
    When method DELETE
    Then status 204

  Scenario: Generate REQUEST_UPDATED_EVENT and verify number of REQUEST records
    Given path 'circulation/check-in-by-barcode'
    And request
    """
    {
    "itemBarcode": "#(itemBarcodeRequest)",
    "userBarcode": "#(userBarcode)",
    "servicePointId": "#(servicePointId)",
    "checkInDate": "#(checkInDate)"
    }
    """
    When method POST
    Then status 200
    Given path 'circulation/requests'
    And request
    """
    {
    "id": "#(requestId)",
    "requesterId": "#(userid)",
    "itemId": "#(itemIdRequest)",
    "instanceId" : "#(instanceId)",
    "requestLevel" : "Item",
    "holdingsRecordId" : "#(holdingsRecordId)",
    "requestType": "Page",
    "fulfilmentPreference": "Hold Shelf",
    "pickupServicePointId": "#(servicePointId)",
    "requestDate": "#(checkInDate)"
    }
    """
    When method POST
    Then status 201
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    * def num_records = $.totalRecords
    Given path 'circulation/requests', requestId
    And request
    """
    {
    "id": "#(requestId)",
    "requesterId": "#(userid)",
    "itemId": "#(itemIdRequest)",
    "instanceId" : "#(instanceId)",
    "requestLevel" : "Item",
    "holdingsRecordId" : "#(holdingsRecordId)",
    "requestType": "Page",
    "fulfilmentPreference": "Hold Shelf",
    "pickupServicePointId": "#(servicePointId)",
    "requestDate": "2020-10-10"
    }
    """
    When method PUT
    Then status 204
    And call pause 5000
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    And match $.totalRecords == num_records + 1
    * def lastAction = get[0] $.logRecords[-1:].action
    And match lastAction == 'Edited'
    Given path 'circulation/requests', requestId
    When method DELETE
    Then status 204

  # Should not be added new log record

  Scenario: Generate REQUEST event with invalid 'itemId' and verify number of REQUEST records
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    * def num_records = $.totalRecords
    Given path 'circulation/requests'
    And request
    """
    {
    "id": "#(requestId)",
    "requesterId": "#(userid)",
    "itemId": "#(itemIdRequest)",
    "instanceId" : "#(instanceId)",
    "requestLevel" : "Item",
    "holdingsRecordId" : "#(holdingsRecordId)",
    "requestType": "Page",
    "fulfilmentPreference": "Hold Shelf",
    "pickupServicePointId": "#(servicePointId)",
    "requestDate": "#(checkInDate)"
    }
    """
    When method POST
    Then status 422
    And call pause 5000
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    And match $.totalRecords == num_records

  Scenario: Generate REQUEST event with invalid 'requesterId' and verify number of REQUEST records
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    * def num_records = $.totalRecords
    Given path 'circulation/requests'
    And request
    """
    {
    "id": "#(requestId)",
    "requesterId": "#(userid)",
    "itemId": "#(itemIdRequest)",
    "instanceId" : "#(instanceId)",
    "requestLevel" : "Item",
    "holdingsRecordId" : "#(holdingsRecordId)",
    "requestType": "Page",
    "fulfilmentPreference": "Hold Shelf",
    "pickupServicePointId": "#(servicePointId)",
    "requestDate": "#(checkInDate)"
    }
    """
    When method POST
    Then status 422
    And call pause 5000
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    And match $.totalRecords == num_records
