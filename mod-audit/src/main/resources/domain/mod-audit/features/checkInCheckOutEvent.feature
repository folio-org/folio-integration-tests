Feature: mod audit data CHECK_IN_CHECK_OUT event

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * callonce variables

  # Should be added new log record

  Scenario: Generate CHECK_IN event with 'In transit' 'itemStatusName' and verify number of CHECK_IN records
    * call read('classpath:global/initTest.feature')
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    * def num_records = $.totalRecords
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
    And match $.item.status.name == 'In transit'
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    And match $.totalRecords == num_records + 1
    * def beforeLastAction = get[0] $.logRecords[-1:].action
    And match beforeLastAction == 'Checked in'
    * call read('classpath:global/destroyTest.feature')

  Scenario: Generate CHECK_OUT event with 'Checked out' 'itemStatusName' and verify number of CHECK_OUT records
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
    And match $.item.status.name == 'Checked out'
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    And match $.totalRecords == num_records + 1
    * def lastAction = get[0] $.logRecords[-1:].action
    And match lastAction == 'Checked out'
    Given path 'circulation/loans', loanId
    When method DELETE
    Then status 204
    * call read('classpath:global/destroyTest.feature')

  Scenario: Generate CHECK_IN event with 'true' 'isLoanClosed' and verify number of CHECK_IN records
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
    * def beforeLastAction = get[0] $.logRecords[-2:].action
    * def lastAction = get[0] $.logRecords[-1:].action
    And match beforeLastAction == 'Checked in'
    And match lastAction == 'Closed loan'
    Given path 'circulation/loans', loanId
    When method DELETE
    Then status 204
    * call read('classpath:global/destroyTest.feature')

  Scenario: Generate CHECK_OUT event with 'false' 'isLoanClosed' and verify number of CHECK_OUT records
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
    And match $.status.name == 'Open'
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    And match $.totalRecords == num_records + 1
    * def lastAction = get[0] $.logRecords[-1:].action
    * def lastObject = get[0] $.logRecords[-1:].object
    And match lastAction == 'Checked out'
    And match lastObject == 'Loan'
    Given path 'circulation/loans', loanId
    When method DELETE
    * call read('classpath:global/destroyTest.feature')

  # Should not be added new log record

  Scenario: Generate CHECK_OUT event with invalid 'userBarcode' and verify number of CHECK_OUT records
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
    "userBarcode": "000111",
    "servicePointId": "#(servicePointId)"
    }
    """
    When method POST
    Then status 422
    And match $.errors[0].message == 'Could not find user with matching barcode'
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    And match $.totalRecords == num_records
    * call read('classpath:global/destroyTest.feature')

  Scenario: Generate CHECK_IN event with invalid 'itemBarcode' and verify number of CHECK_IN records
    * call read('classpath:global/initTest.feature')
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    * def num_records = $.totalRecords
    Given path 'circulation/check-in-by-barcode'
    And request
    """
    {
    "itemBarcode": "000222",
    "userBarcode": "#(userBarcode)",
    "servicePointId": "#(servicePointId)",
    "checkInDate": "#(checkInDate)"
    }
    """
    When method POST
    Then status 422
    And match $.errors[0].message == 'No item with barcode 000222 exists'
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    And match $.totalRecords == num_records
    * call read('classpath:global/destroyTest.feature')

  Scenario: Generate CHECK_OUT event with invalid 'itemBarcode' and verify number of CHECK_OUT records
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
    "itemBarcode": "000000",
    "userBarcode": "#(userBarcode)",
    "servicePointId": "#(servicePointId)"
    }
    """
    When method POST
    Then status 422
    And match $.errors[0].message == 'No item with barcode 000000 could be found'
    Given path 'audit-data/circulation/logs'
    And param limit = 1000000
    When method GET
    Then status 200
    And match $.totalRecords == num_records
    * call read('classpath:global/destroyTest.feature')