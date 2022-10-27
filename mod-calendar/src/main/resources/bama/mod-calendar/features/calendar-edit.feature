Feature: Calendar updating/editing

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def servicePointId = call uuid1

  Scenario: Edit a simple calendar
    * def calendarName = 'Sample calendar'
    * def startDate = '2000-08-01';
    * def endDate = '2000-08-31';
    * def assignments = []
    * def createCalendarRequest = read('samples/createCalendar.json')

    Given path 'calendar/calendars'
    And request createCalendarRequest
    When method POST
    Then status 201
    And def createdCalendarId = $.id

    * def startDate = '2000-08-30'
    * def calendarName = 'Edited name'
    * def createUpdateRequest = read('samples/editCalendar.json')

    Given path 'calendar/calendars/' + createdCalendarId
    And request createUpdateRequest
    When method PUT
    Then status 200
    And match $ contains deep createUpdateRequest
    And match $.normalHours contains only createUpdateRequest.normalHours
    And match $.exceptions contains only createUpdateRequest.exceptions

    Given path 'calendar/calendars'
    When method GET
    Then status 200
    And match $.calendars[0].id == createdCalendarId
    # should contain all properties sent originally
    And match $.calendars[0] contains deep createUpdateRequest
    And match $.calendars[0].normalHours contains only createUpdateRequest.normalHours
    And match $.calendars[0].exceptions contains only createUpdateRequest.exceptions

    # cleanup
    Given path 'calendar/calendars/' + createdCalendarId
    When method DELETE
    Then status 204
