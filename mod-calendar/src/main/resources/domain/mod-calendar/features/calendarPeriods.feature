Feature: Calendar periods

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def startDate = '2120-08-01';
    * def endDate = '2120-08-31';
    * def periodId = call uuid1
    * def servicePointId = call uuid1

  Scenario: Get all periods
    Given path 'calendar', 'periods'
    When method GET
    Then status 200

  Scenario: GET all periods filtered by service point with 200 on success
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar/periods/' + servicePointId + '/period'
    When method GET
    Then status 200
    And match $.openingPeriods[0].name == createPeriodRequest.name

  Scenario: GET all periods filtered by start date with 200 on success
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar', 'periods'
    And param startDate = '2120-08-30'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.openingPeriods[0].openingDay.openingHour[0].startTime == '08:00'
    And match $.openingPeriods[0].openingDay.openingHour[0].endTime == '18:00'
    And match $.openingPeriods[0].openingDay.open == true
    And match $.openingPeriods[0].openingDay.allDay == false

  Scenario: GET all periods filtered by end date with 200 on success
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar', 'periods'
    And param endDate = '2120-08-03'
    When method GET
    Then status 200
    And match $.totalRecords == 2
    And match $.openingPeriods[0].openingDay.openingHour[0].startTime == '08:00'
    And match $.openingPeriods[0].openingDay.openingHour[0].endTime == '18:00'
    And match $.openingPeriods[0].openingDay.open == true
    And match $.openingPeriods[0].openingDay.allDay == false
    And match $.openingPeriods[1].openingDay.openingHour[0].startTime == '00:00'
    And match $.openingPeriods[1].openingDay.openingHour[0].endTime == '23:59'
    And match $.openingPeriods[1].openingDay.open == false
    And match $.openingPeriods[1].openingDay.allDay == true

  Scenario: GET all periods including closed hours with 200 on success
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar', 'periods'
    When method GET
    Then status 200
    And match $.openingPeriods[0].openingDay.open == true
    And match $.openingPeriods[1].openingDay.open == false

  Scenario: GET all periods including exceptional hours with 200 on success
    Given path 'calendar/periods/' + servicePointId + '/period'
    * def exceptionPeriodId = call uuid1
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar', 'periods'
    When method GET
    Then status 200
    And match $.openingPeriods[4].date == '2120-08-06T00:00:00.000+00:00'
    And match $.openingPeriods[4].openingDay.exceptional == false

    Given path 'calendar/periods/' + servicePointId + '/period'
    * def startExceptionDate = '2120-08-06'
    * def endExceptionDate = '2120-08-06'
    * def createExceptionRequest = read('samples/createException.json')
    And request createExceptionRequest
    When method POST
    Then status 201

    Given path 'calendar', 'periods'
    When method GET
    Then status 200
    And match $.openingPeriods[4].date == '2120-08-06T00:00:00.000+00:00'
    And match $.openingPeriods[4].openingDay.exceptional == true

  Scenario: GET library hours period for service point with 200 on success and empty opening days
    Given path 'calendar/periods/' + servicePointId + '/period'
    When method GET
    Then status 200
    And match $.totalRecords == 0

  Scenario: GET library hours period for service point with opening days and 200 on success
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar/periods/' + servicePointId + '/period'
    And param withOpeningDays = true
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.openingPeriods[0].name == createPeriodRequest.name
    And match $.openingPeriods[0].openingDays[0].openingDay.open == true
    And match $.openingPeriods[0].openingDays[0].openingDay.openingHour[0].startTime == '08:00'
    And match $.openingPeriods[0].openingDays[0].openingDay.openingHour[0].endTime == '18:00'

  Scenario: GET library hours period for service point including past openings and with 200 on success
    * def periodName = 'Test period'
    * def startDate = '2020-08-01';
    * def endDate = '2020-08-31';
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar/periods/' + servicePointId + '/period'
    And param withOpeningDays = true
    And param showPast = true
    When method GET
    Then status 200
    And match $.openingPeriods[0].startDate == '2020-08-01T00:00:00.000+00:00'
    And match $.openingPeriods[0].endDate == '2020-08-31T00:00:00.000+00:00'
    And match $.openingPeriods[0].openingDays[0].openingDay.open == true
    And match $.openingPeriods[0].openingDays[0].openingDay.openingHour[0].startTime == '08:00'
    And match $.openingPeriods[0].openingDays[0].openingDay.openingHour[0].endTime == '18:00'

  Scenario: GET library hours period for service point with exceptional hours and 200 on success
    * def exceptionPeriodId = call uuid1

    Given path 'calendar/periods/' + servicePointId + '/period'
    * def startExceptionDate = '2120-08-06'
    * def endExceptionDate = '2120-08-06'
    * def createExceptionRequest = read('samples/createException.json')
    And request createExceptionRequest
    When method POST
    Then status 201

    Given path 'calendar/periods/' + servicePointId + '/period'
    And param withOpeningDays = true
    And param showExceptional = true
    When method GET
    Then status 200
    And match $.openingPeriods[0].startDate == '2120-08-06T00:00:00.000+00:00'
    And match $.openingPeriods[0].endDate == '2120-08-06T00:00:00.000+00:00'
    And match $.openingPeriods[0].openingDays[0].openingDay.openingHour[0].startTime == '00:00'
    And match $.openingPeriods[0].openingDays[0].openingDay.openingHour[0].endTime == '23:59'
    And match $.openingPeriods[0].openingDays[0].openingDay.open == false
    And match $.openingPeriods[0].name == createExceptionRequest.name

  Scenario: GET opening hours for given periodId with 200 on success
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar/periods/' + servicePointId + '/period/' + periodId
    When method GET
    Then status 200
    And match $.name == createPeriodRequest.name

  Scenario: GET opening hours for given periodId should return 404 if periodId does not exist
    Given path 'calendar/periods/' + servicePointId + '/period/' + periodId
    When method GET
    Then status 404
    And match $.errors[0].message == 'Openings with id \'' + periodId + '\' is not found'

  Scenario: POST calendar period by service point id should return created period and 201 on success
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

  Scenario: POST calendar period by service point id should return 422 if period is invalid
    * def createPeriodRequest = read('samples/createPeriodWithNoStartDate.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'must not be null'
    And match $.errors[0].parameters[0].key == 'startDate'

  Scenario: POST calendar period by service point id should return 400 if opening days are empty
    * def createPeriodRequest = read('samples/createPeriodWithEmptyOpeningDays.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 400
    And match $ contains 'Not valid json object. Missing field(s)'

  Scenario: POST calendar period by service point id should return 400 if service point id is empty
    * def servicePointIdUrl = call uuid1
    * def periodName = 'Test period'
    * def servicePointId = ''
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointIdUrl + '/period'
    And request createPeriodRequest
    When method POST
    Then status 400
    And match $ contains 'Not valid json object. Missing field(s)'

  Scenario: POST calendar period by service point id should return 400 if name is empty
    * def servicePointIdUrl = call uuid1
    * def periodName = ''
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointIdUrl + '/period'
    And request createPeriodRequest
    When method POST
    Then status 400
    And match $ contains 'Not valid json object. Missing field(s)'

  Scenario: POST calendar period by service point id should return 400 if id is empty
    * def periodId = ''
    * def servicePointIdUrl = call uuid1
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointIdUrl + '/period'
    And request createPeriodRequest
    When method POST
    Then status 400
    And match $ contains 'Not valid json object. Missing field(s)'

  Scenario: POST calendar period by service point id should return 422 if periods overlap
    * def periodName = 'Test period1'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    * def periodId = call uuid1
    * def periodName = 'Test period2'
    * def startDate = '2120-08-31';
    * def endDate = '2120-09-30';
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'The date range entered overlaps with another calendar for this service point. Please correct the date range or enter the hours as exceptions.'

  Scenario: DELETE library hours period by id should return 204 on success
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar/periods/' + servicePointId + '/period/' + periodId
    When method DELETE
    Then status 204

  Scenario: DELETE library hours period by id should return 404 if openings do not exist
    Given path 'calendar/periods/' + servicePointId + '/period/' + periodId
    When method DELETE
    Then status 404

  Scenario: PUT library hours period by id should return 204 on success
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    * def periodName = 'Test period updated'
    * def updatedPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period/' + periodId
    And request updatedPeriodRequest
    When method PUT
    Then status 204

    Given path 'calendar/periods/' + servicePointId + '/period/' + periodId
    When method GET
    Then status 200
    And match $.name == periodName

  Scenario: PUT library hours period by id should return 422 if period is invalid
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')
    * def updatedInvalidPeriodRequest = read('samples/createPeriodWithNoStartDate.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar/periods/' + servicePointId + '/period/' + periodId
    And request updatedInvalidPeriodRequest
    When method PUT
    Then status 422
    And match $.errors[0].message == 'must not be null'
    And match $.errors[0].parameters[0].key == 'startDate'

  Scenario: PUT library hours period by id should return 422 if periods overlap
    * def periodName = 'Test period1'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    * def periodId = call uuid1
    * def periodName = 'Test period2'
    * def startDate = '2120-08-31';
    * def endDate = '2120-09-30';
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period/' + periodId
    And request createPeriodRequest
    When method PUT
    Then status 422
    And match $.errors[0].message == 'The date range entered overlaps with another calendar for this service point. Please correct the date range or enter the hours as exceptions.'

  Scenario: GET calculated due date for the requested date should return 200 and resulting period
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar/periods/' + servicePointId + '/calculateopening'
    And param requestedDate = '2120-08-13'
    When method GET
    Then status 200
    And match response.openingDays[0].openingDay.date == '2120-08-12T00:00:00.000+00:00'
    And match response.openingDays[0].openingDay.openingHour[0].startTime == '08:00'
    And match response.openingDays[0].openingDay.openingHour[0].endTime == '18:00'
    And match response.openingDays[1].openingDay.date == '2120-08-13T00:00:00.000+00:00'
    And match response.openingDays[1].openingDay.openingHour[0].startTime == '08:00'
    And match response.openingDays[1].openingDay.openingHour[0].endTime == '18:00'
    And match response.openingDays[2].openingDay.date == '2120-08-16T00:00:00.000+00:00'
    And match response.openingDays[2].openingDay.openingHour[0].startTime == '08:00'
    And match response.openingDays[2].openingDay.openingHour[0].endTime == '18:00'

  Scenario: GET calculated due date for the requested date should return 400 if date was malformed
    Given path 'calendar/periods/' + servicePointId + '/calculateopening'
    And param requestedDate = 'malformed date'
    When method GET
    Then status 400