Feature: Calendar updating/editing

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json, text/plain' }
    * def paramLimit = '2147483647'
    * def servicePointId = call uuid1

  Scenario: Edit a simple calendar
    * def calendarName = 'Sample calendar'
    * def startDate = '2000-08-01'
    * def endDate = '2000-08-31'
    * def assignments = []
    * def createCalendarRequest = read('classpath:bama/mod-calendar/features/samples/createCalendar.json')

    Given path 'calendar', 'calendars'
    And request createCalendarRequest
    When method POST
    Then status 201
    And def createdCalendarId = $.id

    * def startDate = '2000-08-30'
    * def calendarName = 'Edited name'
    * def createUpdateRequest = read('classpath:bama/mod-calendar/features/samples/editCalendar.json')

    Given path 'calendar', 'calendars', createdCalendarId
    And request createUpdateRequest
    When method PUT
    Then status 200
    And match $ contains deep createUpdateRequest
    And match $.normalHours contains only createUpdateRequest.normalHours
    And match $.exceptions contains only createUpdateRequest.exceptions

    Given path 'calendar', 'calendars'
    And param limit = paramLimit
    When method GET
    Then status 200
    And def calendar = karate.filter(response.calendars, i => i.id == createdCalendarId).shift()
    # should contain all properties sent originally
    And match calendar contains deep createUpdateRequest
    And match calendar.normalHours contains only createUpdateRequest.normalHours
    And match calendar.exceptions contains only createUpdateRequest.exceptions

    # cleanup
    Given path 'calendar', 'calendars', createdCalendarId
    When method DELETE
    Then status 204
