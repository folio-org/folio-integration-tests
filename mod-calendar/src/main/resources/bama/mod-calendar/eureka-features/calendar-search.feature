Feature: Calendar searching

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json, text/plain' }
    * def servicePointId1 = call uuid1
    * def servicePointId2 = call uuid2

  Scenario: Get all calendars
    Given path 'calendar', 'calendars'
    When method GET
    Then status 200

  Scenario: GET all calendars filtered by service point
    * def calendarName = 'Sample calendar on SP1'
    * def startDate = '2000-08-01'
    * def endDate = '2000-08-31'
    * def assignments = ['#(servicePointId1)']
    * def createCalendarRequest = read('classpath:bama/mod-calendar/features/samples/createCalendar.json')

    Given path 'calendar', 'calendars'
    And request createCalendarRequest
    When method POST
    Then status 201
    And def createdCalendarId = $.id

    Given path 'calendar', 'calendars'
    And param limit = '2147483647'
    When method GET
    Then status 200
    And match $.calendars[*].id contains createdCalendarId
    And match $.calendars[*] contains deep createCalendarRequest

    Given path 'calendar', 'calendars'
    And param limit = '2147483647'
    And param servicePointId = servicePointId1
    When method GET
    Then status 200
    And match $.calendars[*].id contains createdCalendarId
    And match $.calendars[*] contains deep createCalendarRequest

    Given path 'calendar', 'calendars'
    And param limit = '2147483647'
    And param servicePointId = servicePointId2
    When method GET
    Then status 200
    And match $.calendars[*].id !contains createdCalendarId

    # cleanup
    Given path 'calendar', 'calendars', createdCalendarId
    When method DELETE
    Then status 204

    Given path 'calendar', 'calendars'
    And param limit = '2147483647'
    When method GET
    Then status 200
    And match $.calendars[*].id !contains createdCalendarId

  Scenario: GET all calendars filtered by date
    * def calendarName = 'Sample calendar'
    * def assignments = []
    * def startDate = '2000-08-01'
    * def endDate = '2000-08-31'
    * def createCalendarRequest = read('classpath:bama/mod-calendar/features/samples/createCalendar.json')

    Given path 'calendar', 'calendars'
    And request createCalendarRequest
    When method POST
    Then status 201
    And def createdCalendarId = $.id

    Given path 'calendar', 'calendars'
    And param limit = '2147483647'
    And param startDate = '2000-07-01'
    When method GET
    Then status 200
    And match $.calendars[*].id contains createdCalendarId
    And match $.calendars[*] contains deep createCalendarRequest

    Given path 'calendar', 'calendars'
    And param limit = '2147483647'
    And param startDate = '2000-08-01'
    When method GET
    Then status 200
    And match $.calendars[*].id contains createdCalendarId
    And match $.calendars[*] contains deep createCalendarRequest

    Given path 'calendar', 'calendars'
    And param limit = '2147483647'
    And param startDate = '2000-10-01'
    When method GET
    Then status 200
    And match $.calendars[*].id !contains createdCalendarId

    Given path 'calendar', 'calendars'
    And param limit = '2147483647'
    And param endDate = '2000-10-01'
    When method GET
    Then status 200
    And match $.calendars[*].id contains createdCalendarId
    And match $.calendars[*] contains deep createCalendarRequest

    Given path 'calendar', 'calendars'
    And param limit = '2147483647'
    And param endDate = '2000-08-01'
    When method GET
    Then status 200
    And match $.calendars[*].id contains createdCalendarId
    And match $.calendars[*] contains deep createCalendarRequest

    Given path 'calendar', 'calendars'
    And param limit = '2147483647'
    And param endDate = '2000-07-01'
    When method GET
    Then status 200
    And match $.calendars[*].id !contains createdCalendarId

    Given path 'calendar', 'calendars'
    And param limit = '2147483647'
    And param startDate = '2000-07-01'
    And param endDate = '2000-07-02'
    When method GET
    Then status 200
    And match $.calendars[*].id !contains createdCalendarId

    Given path 'calendar', 'calendars'
    And param limit = '2147483647'
    And param startDate = '2000-07-01'
    And param endDate = '2000-08-01'
    When method GET
    Then status 200
    And match $.calendars[*].id contains createdCalendarId
    And match $.calendars[*] contains deep createCalendarRequest

    Given path 'calendar', 'calendars'
    And param limit = '2147483647'
    And param startDate = '2000-07-01'
    And param endDate = '2000-08-31'
    When method GET
    Then status 200
    And match $.calendars[*].id contains createdCalendarId
    And match $.calendars[*] contains deep createCalendarRequest

    Given path 'calendar', 'calendars'
    And param limit = '2147483647'
    And param startDate = '2000-08-01'
    And param endDate = '2000-08-31'
    When method GET
    Then status 200
    And match $.calendars[*].id contains createdCalendarId
    And match $.calendars[*] contains deep createCalendarRequest

    Given path 'calendar', 'calendars'
    And param limit = '2147483647'
    And param startDate = '2000-08-02'
    And param endDate = '2000-10-31'
    When method GET
    Then status 200
    And match $.calendars[*].id contains createdCalendarId
    And match $.calendars[*] contains deep createCalendarRequest

    Given path 'calendar', 'calendars'
    And param limit = '2147483647'
    And param startDate = '2000-09-01'
    And param endDate = '2000-10-31'
    When method GET
    Then status 200
    And match $.calendars[*].id !contains createdCalendarId

    # returns none as this is an invalid filter
    Given path 'calendar', 'calendars'
    And param limit = '2147483647'
    And param startDate = '2000-09-01'
    And param endDate = '2000-07-01'
    When method GET
    Then status 200
    And match $.calendars[*].id !contains createdCalendarId

    # cleanup
    Given path 'calendar', 'calendars', createdCalendarId
    When method DELETE
    Then status 204