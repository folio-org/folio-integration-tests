Feature: Calendar searching

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def servicePointId = call uuid1

  Scenario: Test complex calendar daily opening information
    * def calendarName = 'Sample complex calendar'
    * def assignments = [#(servicePointId)]
    * def createCalendarRequest = read('samples/createComplexCalendar.json')

    Given path 'calendar/calendars'
    And request createCalendarRequest
    When method POST
    Then status 201
    And def createdCalendarId = $.id
    # should contain all properties sent originally
    And match $ contains deep createCalendarRequest
    And match $.normalHours contains only createCalendarRequest.normalHours
    And match $.exceptions contains only createCalendarRequest.exceptions

    Given path 'calendar/dates/' + servicePointId + '/all-openings'
    And param startDate = "2000-01-01"
    And param endDate = "2000-04-01"
    And param includeClosed = true
    And param limit = 1000
    When method GET
    Then status 200
    And match $ == read('samples/dailyOpeningsWithClosuresComplex.json')

    Given path 'calendar/dates/' + servicePointId + '/all-openings'
    And param startDate = "2000-01-01"
    And param endDate = "2000-04-01"
    And param includeClosed = false
    And param limit = 1000
    When method GET
    Then status 200
    And match $ == read('samples/dailyOpeningsWithoutClosuresComplex.json')

    # cleanup
    Given path 'calendar/calendars/' + createdCalendarId
    When method DELETE
    Then status 204
