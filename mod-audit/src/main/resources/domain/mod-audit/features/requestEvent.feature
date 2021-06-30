Feature: mod audit data REQUEST event

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * callonce variables

  # Should be added new log record

  Scenario: Generate REQUEST_CREATED_EVENT and verify number of REQUEST records
    * call read('classpath:global/initTest.feature')
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
    "itemId": "#(itemId)",
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
    And match $.totalRecords == num_records + 1
    * def lastAction = get[0] $.logRecords[-1:].action
    And match lastAction == 'Created'
    Given path 'circulation/requests', requestId
    When method DELETE
    * call read('classpath:global/destroyTest.feature')

  Scenario: Generate REQUEST_UPDATED_EVENT and verify number of REQUEST records
    * call read('classpath:global/initTest.feature')
    Given path 'circulation/requests'
    And request
    """
    {
    "id": "#(requestId)",
    "requesterId": "#(userid)",
    "itemId": "#(itemId)",
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
    "itemId": "#(itemId)",
    "requestType": "Page",
    "fulfilmentPreference": "Hold Shelf",
    "pickupServicePointId": "#(servicePointId)",
    "requestDate": "2020-10-10"
    }
    """
    When method PUT
    Then status 204
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    And match $.totalRecords == num_records + 1
    * def lastAction = get[0] $.logRecords[-1:].action
    And match lastAction == 'Edited'
    Given path 'circulation/requests', requestId
    When method DELETE
    * call read('classpath:global/destroyTest.feature')

  # Should not be added new log record

  Scenario: Generate REQUEST event with invalid 'itemId' and verify number of REQUEST records
    * call read('classpath:global/initTest.feature')
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
    "itemId": "9ea1fd0b-0259-4edb-95a3-eb2f9a000000",
    "requestType": "Page",
    "fulfilmentPreference": "Hold Shelf",
    "pickupServicePointId": "#(servicePointId)",
    "requestDate": "#(checkInDate)"
    }
    """
    When method POST
    Then status 422
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    And match $.totalRecords == num_records
    * call read('classpath:global/destroyTest.feature')

  Scenario: Generate REQUEST event with invalid 'requesterId' and verify number of REQUEST records
    * call read('classpath:global/initTest.feature')
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
    "requesterId": "9ea1fd0b-0259-4edb-95a3-eb2f9a000000",
    "itemId": "#(itemId)",
    "requestType": "Page",
    "fulfilmentPreference": "Hold Shelf",
    "pickupServicePointId": "#(servicePointId)",
    "requestDate": "#(checkInDate)"
    }
    """
    When method POST
    Then status 422
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    And match $.totalRecords == num_records
    * call read('classpath:global/destroyTest.feature')
