Feature: Calendar searching

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def servicePointId = call uuid1

  Scenario: Test complex calendar surrounding opening reports
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

    * table expectedJan1
      | date         | allDay | open  | exceptional | openings                                    |
      | '1999-12-31' | true   | false | false       | []                                          |
      | '2000-01-01' | true   | false | false       | []                                          |
      | '2000-01-03' | false  | true  | false       | [{startTime:"07:00:00",endTime:"23:59:00"}] |

    Given path 'calendar/dates/' + servicePointId + '/surrounding-openings'
    And param date = "2000-01-01"
    When method GET
    Then status 200
    And match $.openings == expectedJan1

    * table expectedJan6
      | date         | allDay | open | exceptional | openings                                                                              |
      | '2000-01-05' | true   | true | false       | [{startTime:"00:00:00",endTime:"23:59:00"}]                                           |
      | '2000-01-06' | true   | true | false       | [{startTime:"00:00:00",endTime:"23:59:00"}]                                           |
      | '2000-01-07' | false  | true | false       | [{startTime:"07:00:00",endTime:"12:00:00"},{startTime:"13:00:00",endTime:"22:00:00"}] |

    Given path 'calendar/dates/' + servicePointId + '/surrounding-openings'
    And param date = "2000-01-06"
    When method GET
    Then status 200
    And match $.openings == expectedJan6

    * table expectedJan15
      | date         | allDay | open  | exceptional | exceptionName         | openings                                                                              |
      | '2000-01-14' | false  | true  | false       |                       | [{startTime:"07:00:00",endTime:"12:00:00"},{startTime:"13:00:00",endTime:"22:00:00"}] |
      | '2000-01-15' | false  | true  | true        | 'Exceptional opening' | [{startTime:"07:00:00",endTime:"23:59:00"}]                                           |
      | '2000-01-16' | true   | true  | true        | 'Exceptional opening' | [{startTime:"00:00:00",endTime:"23:59:00"}]                                           |

    Given path 'calendar/dates/' + servicePointId + '/surrounding-openings'
    And param date = "2000-01-15"
    When method GET
    Then status 200
    And match $.openings == expectedJan15

    * table expectedJan21
      | date         | allDay | open  | exceptional | exceptionName         | openings                                    |
      | '2000-01-20' | false  | true  | true        | 'Exceptional opening' | [{startTime:"00:00:00",endTime:"23:00:00"}] |
      | '2000-01-21' | true   | false | true        | 'Exceptional opening' | []                                          |
      | '2000-01-25' | false  | true  | true        | 'Exceptional opening' | [{startTime:"07:00:00",endTime:"23:59:00"}] |

    Given path 'calendar/dates/' + servicePointId + '/surrounding-openings'
    And param date = "2000-01-21"
    When method GET
    Then status 200
    And match $.openings == expectedJan21

    * table expectedJan31
      | date         | allDay | open | exceptional | exceptionName         | openings                                    |
      | '2000-01-30' | true   | true | true        | 'Exceptional opening' | [{startTime:"00:00:00",endTime:"23:59:00"}] |
      | '2000-01-31' | false  | true | true        | 'Exceptional opening' | [{startTime:"00:00:00",endTime:"23:00:00"}] |
      | '2000-02-01' | true   | true | false       |                       | [{startTime:"00:00:00",endTime:"23:59:00"}] |

    Given path 'calendar/dates/' + servicePointId + '/surrounding-openings'
    And param date = "2000-01-31"
    When method GET
    Then status 200
    And match $.openings == expectedJan31

    * table expectedFeb1
      | date         | allDay | open | exceptional | exceptionName         | openings                                    |
      | '2000-01-31' | false  | true | true        | 'Exceptional opening' | [{startTime:"00:00:00",endTime:"23:00:00"}] |
      | '2000-02-01' | true   | true | false       |                       | [{startTime:"00:00:00",endTime:"23:59:00"}] |
      | '2000-02-02' | true   | true | false       |                       | [{startTime:"00:00:00",endTime:"23:59:00"}] |

    Given path 'calendar/dates/' + servicePointId + '/surrounding-openings'
    And param date = "2000-02-01"
    When method GET
    Then status 200
    And match $.openings == expectedFeb1

    * table expectedMar13
      | date         | allDay | open  | exceptional | exceptionName         | openings                                    |
      | '2000-02-29' | true   | true  | false       |                       | [{startTime:"00:00:00",endTime:"23:59:00"}] |
      | '2000-03-13' | true   | false | true        | 'Exceptional closure' | []                                          |
      | '2000-04-03' | false  | true  | false       |                       | [{startTime:"07:00:00",endTime:"23:59:00"}] |

    Given path 'calendar/dates/' + servicePointId + '/surrounding-openings'
    And param date = "2000-03-13"
    When method GET
    Then status 200
    And match $.openings == expectedMar13

    # cleanup
    Given path 'calendar/calendars/' + createdCalendarId
    When method DELETE
    Then status 204
