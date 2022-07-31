Feature: Calendar searching

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def servicePointId1 = call uuid1
    * def servicePointId2 = call uuid2

  Scenario: Get all calendars
    Given path 'calendar/calendars'
    When method GET
    Then status 200

  Scenario: GET all calendars filtered by service point
    * def calendarName = 'Sample calendar on SP1'
    * def startDate = '2000-08-01';
    * def endDate = '2000-08-31';
    * def assignments = [#(servicePointId1)]
    * def createCalendarRequest = read('samples/createCalendar.json')

    Given path 'calendar/calendars'
    And request createCalendarRequest
    When method POST
    Then status 201
    And def createdCalendarId = $.id

    Given path 'calendar/calendars'
    When method GET
    Then status 200
    And match $.calendars[0].id == createdCalendarId
    And match $.calendars[0] contains deep createCalendarRequest
    And match $.totalRecords == 1

    Given path 'calendar/calendars'
    And param servicePointId = servicePointId1
    When method GET
    Then status 200
    And match $.calendars[0].id == createdCalendarId
    And match $.calendars[0] contains deep createCalendarRequest
    And match $.totalRecords == 1

    Given path 'calendar/calendars'
    And param servicePointId = servicePointId2
    When method GET
    Then status 200
    And match $.totalRecords == 0

    # cleanup
    Given path 'calendar/calendars/' + createdCalendarId
    When method DELETE
    Then status 204

    Given path 'calendar/calendars'
    When method GET
    Then status 200
    And match $.totalRecords == 0

  Scenario: GET all calendars filtered by date
    * def calendarName = 'Sample calendar'
    * def assignments = []
    * def startDate = '2000-08-01';
    * def endDate = '2000-08-31';
    * def createCalendarRequest = read('samples/createCalendar.json')

    Given path 'calendar/calendars'
    And request createCalendarRequest
    When method POST
    Then status 201
    And def createdCalendarId = $.id

    Given path 'calendar/calendars'
    And param startDate = '2000-07-01'
    When method GET
    Then status 200
    And match $.calendars[0].id == createdCalendarId
    And match $.calendars[0] contains deep createCalendarRequest
    And match $.totalRecords == 1

    Given path 'calendar/calendars'
    And param startDate = '2000-08-01'
    When method GET
    Then status 200
    And match $.calendars[0].id == createdCalendarId
    And match $.calendars[0] contains deep createCalendarRequest
    And match $.totalRecords == 1

    Given path 'calendar/calendars'
    And param startDate = '2000-10-01'
    When method GET
    Then status 200
    And match $.totalRecords == 0

    Given path 'calendar/calendars'
    And param endDate = '2000-10-01'
    When method GET
    Then status 200
    And match $.calendars[0].id == createdCalendarId
    And match $.calendars[0] contains deep createCalendarRequest
    And match $.totalRecords == 1

    Given path 'calendar/calendars'
    And param endDate = '2000-08-01'
    When method GET
    Then status 200
    And match $.calendars[0].id == createdCalendarId
    And match $.calendars[0] contains deep createCalendarRequest
    And match $.totalRecords == 1

    Given path 'calendar/calendars'
    And param endDate = '2000-07-01'
    When method GET
    Then status 200
    And match $.totalRecords == 0

    Given path 'calendar/calendars'
    And param startDate = '2000-07-01'
    And param endDate = '2000-07-02'
    When method GET
    Then status 200
    And match $.totalRecords == 0

    Given path 'calendar/calendars'
    And param startDate = '2000-07-01'
    And param endDate = '2000-08-01'
    When method GET
    Then status 200
    And match $.calendars[0].id == createdCalendarId
    And match $.calendars[0] contains deep createCalendarRequest
    And match $.totalRecords == 1

    Given path 'calendar/calendars'
    And param startDate = '2000-07-01'
    And param endDate = '2000-08-31'
    When method GET
    Then status 200
    And match $.calendars[0].id == createdCalendarId
    And match $.calendars[0] contains deep createCalendarRequest
    And match $.totalRecords == 1

    Given path 'calendar/calendars'
    And param startDate = '2000-08-01'
    And param endDate = '2000-08-31'
    When method GET
    Then status 200
    And match $.calendars[0].id == createdCalendarId
    And match $.calendars[0] contains deep createCalendarRequest
    And match $.totalRecords == 1

    Given path 'calendar/calendars'
    And param startDate = '2000-08-02'
    And param endDate = '2000-10-31'
    When method GET
    Then status 200
    And match $.calendars[0].id == createdCalendarId
    And match $.calendars[0] contains deep createCalendarRequest
    And match $.totalRecords == 1

    Given path 'calendar/calendars'
    And param startDate = '2000-09-01'
    And param endDate = '2000-10-31'
    When method GET
    Then status 200
    And match $.totalRecords == 0

    # returns none as this is an invalid filter
    Given path 'calendar/calendars'
    And param startDate = '2000-09-01'
    And param endDate = '2000-07-01'
    When method GET
    Then status 200
    And match $.totalRecords == 0

    # cleanup
    Given path 'calendar/calendars/' + createdCalendarId
    When method DELETE
    Then status 204
