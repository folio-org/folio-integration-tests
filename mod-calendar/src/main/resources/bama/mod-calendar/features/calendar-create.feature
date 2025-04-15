Feature: Calendar creating

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json, text/plain' }
    * def paramLimit = '2147483647'
    * def servicePointId1 = call uuid1
    * def servicePointId2 = call uuid2

  Scenario: Create a simple calendar with no exceptions
    * def calendarName = 'Sample calendar'
    * def startDate = '2000-08-01'
    * def endDate = '2000-08-31'
    * def assignments = ['#(servicePointId1)', '#(servicePointId2)']
    * def createCalendarRequest = read('classpath:bama/mod-calendar/features/samples/createCalendar.json')

    Given path 'calendar', 'calendars'
    And request createCalendarRequest
    When method POST
    Then status 201
    And def createdCalendarId = $.id
    # should contain all properties sent originally
    And match $ contains deep createCalendarRequest
    And match $.normalHours contains only createCalendarRequest.normalHours
    And match $.exceptions contains only createCalendarRequest.exceptions

    Given path 'calendar', 'calendars'
    And param limit = paramLimit
    When method GET
    Then status 200
    And def calendar = karate.filter(response.calendars, i => i.id == createdCalendarId).shift()
    # should contain all properties sent originally
    And match calendar contains deep createCalendarRequest
    And match calendar.normalHours contains only createCalendarRequest.normalHours
    And match calendar.exceptions contains only createCalendarRequest.exceptions

    # cleanup
    Given path 'calendar', 'calendars', createdCalendarId
    When method DELETE
    Then status 204

  Scenario: Create an exceptional calendar with no exceptions
    * def calendarName = 'Sample complex calendar'
    * def assignments = ['#(servicePointId1)', '#(servicePointId2)']
    * def createCalendarRequest = read('classpath:bama/mod-calendar/features/samples/createComplexCalendar.json')

    Given path 'calendar', 'calendars'
    And request createCalendarRequest
    When method POST
    Then status 201
    And def createdCalendarId = $.id
    # should contain all properties sent originally
    And match $ contains deep createCalendarRequest
    And match $.normalHours contains only createCalendarRequest.normalHours
    And match $.exceptions contains only createCalendarRequest.exceptions

    Given path 'calendar', 'calendars'
    And param limit = paramLimit
    When method GET
    Then status 200
    And def calendar = karate.filter(response.calendars, i => i.id == createdCalendarId).shift()
    # should contain all properties sent originally
    And match calendar contains deep createCalendarRequest
    And match calendar.normalHours contains only createCalendarRequest.normalHours
    And match calendar.exceptions contains deep createCalendarRequest.exceptions

    # cleanup
    Given path 'calendar', 'calendars', createdCalendarId
    When method DELETE
    Then status 204

  Scenario: Create overlapping calendars with different assignments
    * def calendarName = 'Sample calendar'
    * def startDate = '2000-08-01'
    * def endDate = '2000-08-31'
    * def assignments = ['#(servicePointId1)']
    * def createCalendarRequest = read('classpath:bama/mod-calendar/features/samples/createCalendar.json')

    Given path 'calendar', 'calendars'
    And request createCalendarRequest
    When method POST
    Then status 201
    And def createdCalendarId1 = $.id
    # should contain all properties sent originally
    And match $ contains deep createCalendarRequest

    * def assignments = ['#(servicePointId2)']
    * def createCalendarRequest = read('classpath:bama/mod-calendar/features/samples/createCalendar.json')

    Given path 'calendar', 'calendars'
    And request createCalendarRequest
    When method POST
    Then status 201
    And def createdCalendarId2 = $.id
    # should contain all properties sent originally
    And match $ contains deep createCalendarRequest

    * def assignments = []
    * def createCalendarRequest = read('classpath:bama/mod-calendar/features/samples/createCalendar.json')

    Given path 'calendar', 'calendars'
    And request createCalendarRequest
    When method POST
    Then status 201
    And def createdCalendarId3 = $.id
    # should contain all properties sent originally
    And match $ contains deep createCalendarRequest

    Given path 'calendar', 'calendars'
    And param limit = paramLimit
    When method GET
    Then status 200
    # should contain all properties sent originally
    And match $..id contains ['#(createdCalendarId1)', '#(createdCalendarId2)', '#(createdCalendarId3)']

    # cleanup
    Given path 'calendar', 'calendars'
    And param id = ['#(createdCalendarId1)', '#(createdCalendarId2)', '#(createdCalendarId3)']
    When method DELETE
    Then status 204

  Scenario: Create overlapping calendars with same assignments
    * def calendarName = 'Sample calendar'
    * def startDate = '2000-08-01'
    * def endDate = '2000-08-31'
    * def assignments = ['#(servicePointId1)']
    * def createCalendarRequest = read('classpath:bama/mod-calendar/features/samples/createCalendar.json')

    Given path 'calendar', 'calendars'
    And request createCalendarRequest
    When method POST
    Then status 201
    And def createdCalendarId = $.id
    # should contain all properties sent originally
    And match $ contains deep createCalendarRequest

    Given path 'calendar', 'calendars'
    And request createCalendarRequest
    When method POST
    Then status 409
    And match $.errors contains deep {code: "calendarDateOverlap"}

    # cleanup
    Given path 'calendar', 'calendars', createdCalendarId
    When method DELETE
    Then status 204