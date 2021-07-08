Feature: mod audit data LOAN event

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * callonce variables

  # Should be added new log record

  Scenario: Generate LOAN event with 'Closed' 'action' and verify number of LOAN records
    * call read('classpath:global/initTest.feature')
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    * def num_records = $.totalRecords
    Given path 'circulation/check-out-by-barcode'
    And request
    """
    {
    "itemBarcode": "#(itemBarcode)",
    "userBarcode": "#(userBarcode)",
    "servicePointId": "#(servicePointId)"
    }
    """
    When method POST
    Then status 201
    * def loanId = $.id
    Given path 'circulation/check-in-by-barcode'
    And request
    """
    {
    "itemBarcode": "#(itemBarcode)",
    "userBarcode": "#(userBarcode)",
    "servicePointId": "#(servicePointId)",
    "checkInDate": "#(checkInDate)"
    }
    """
    When method POST
    Then status 200
    And match $.loan.status.name == 'Closed'
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    And match $.totalRecords == num_records + 3
    * def lastAction = get[0] $.logRecords[-1:].action
    And match lastAction == 'Closed loan'
    Given path 'circulation/loans', loanId
    When method DELETE
    Then status 204
    * call read('classpath:global/destroyTest.feature')

  Scenario: Generate LOAN event with 'Renewed' 'action' and verify number of LOAN records (+1 additional record for Renewed, see CIRC-1165)
    * call read('classpath:global/initTest.feature')
    Given path 'circulation/check-out-by-barcode'
    And request
    """
    {
    "itemBarcode": "#(itemBarcode)",
    "userBarcode": "#(userBarcode)",
    "servicePointId": "#(servicePointId)"
    }
    """
    When method POST
    Then status 201
    * def loanId = $.id
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    * def num_records = $.totalRecords
    Given path 'circulation/renew-by-barcode'
    And request
    """
    {
    "itemBarcode": "#(itemBarcode)",
    "userBarcode": "#(userBarcode)",
    "servicePointId": "#(servicePointId)"
    }
    """
    When method POST
    Then status 200
    And match $.status.name == 'Open'
    And match $.action == 'renewed'
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    And match $.totalRecords == num_records + 2
    Given path 'circulation/loans', loanId
    When method DELETE
    Then status 204
    * call read('classpath:global/destroyTest.feature')

  # Should not be added new log record

  Scenario: Generate LOAN event with invalid 'itemBarcode' and verify number of LOAN records
    * call read('classpath:global/initTest.feature')
    Given path 'circulation/check-out-by-barcode'
    And request
    """
    {
    "itemBarcode": "#(itemBarcode)",
    "userBarcode": "#(userBarcode)",
    "servicePointId": "#(servicePointId)"
    }
    """
    When method POST
    Then status 201
    * def loanId = $.id
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    * def num_records = $.totalRecords
    Given path 'circulation/check-in-by-barcode'
    And request
    """
    {
    "itemBarcode": "000",
    "userBarcode": "#(userBarcode)",
    "servicePointId": "#(servicePointId)",
    "checkInDate": "#(checkInDate)"
    }
    """
    When method POST
    Then status 422
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    And match $.totalRecords == num_records
    Given path 'circulation/loans', loanId
    When method DELETE
    Then status 204
    * call read('classpath:global/destroyTest.feature')