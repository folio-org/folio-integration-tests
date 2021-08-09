Feature: Calendar periods

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def startDate = '2030-08-01';
    * def endDate = '2030-08-31';

  Scenario: Get all periods
    Given path 'calendar', 'periods'
    When method GET
    Then status 200

  Scenario: GET all periods filtered by service point with 200 on success
    * def periodId = call uuid1
    * def servicePointId = call uuid1
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
    * def periodId = call uuid1
    * def servicePointId = call uuid1
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar', 'periods'
    And param startDate = '2030-08-30'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.openingPeriods[0].openingDay.openingHour[0].startTime == '08:00'
    And match $.openingPeriods[0].openingDay.openingHour[0].endTime == '18:00'
    And match $.openingPeriods[0].openingDay.open == true
    And match $.openingPeriods[0].openingDay.allDay == false

  Scenario: GET all periods filtered by end date with 200 on success
    * def periodId = call uuid1
    * def servicePointId = call uuid1
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar', 'periods'
    And param endDate = '2030-08-03'
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
    * def periodId = call uuid1
    * def servicePointId = call uuid1
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
    * def servicePointId = call uuid1

    Given path 'calendar/periods/' + servicePointId + '/period'
    * def periodId = call uuid1
    * def exceptionPeriodId = call uuid1
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar', 'periods'
    When method GET
    Then status 200
    And match $.openingPeriods[4].date == '2030-08-06T00:00:00.000+00:00'
    And match $.openingPeriods[4].openingDay.exceptional == false

    Given path 'calendar/periods/' + servicePointId + '/period'
    * def startExceptionDate = '2030-08-06'
    * def endExceptionDate = '2030-08-06'
    * def createExceptionRequest = read('samples/createException.json')
    And request createExceptionRequest
    When method POST
    Then status 201

    Given path 'calendar', 'periods'
    When method GET
    Then status 200
    And match $.openingPeriods[4].date == '2030-08-06T00:00:00.000+00:00'
    And match $.openingPeriods[4].openingDay.exceptional == true

  Scenario: GET library hours period for service point with 200 on success
    * def servicePointId = call uuid1

    Given path 'calendar/periods/' + servicePointId + '/period'
    When method GET
    Then status 200

  Scenario: GET library hours period for service point with opening days and 200 on success
    * def periodId = call uuid1
    * def servicePointId = call uuid1
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar/periods/' + servicePointId + '/period'
    When method GET
    Then status 200
    And match $.totalRecords == 1
    And match $.openingPeriods[0].name == createPeriodRequest.name

  Scenario: GET opening hours for given periodId with 200 on success
    * def periodId = call uuid1
    * def servicePointId = call uuid1
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
    * def periodId = call uuid1
    * def servicePointId = call uuid1

    Given path 'calendar/periods/' + servicePointId + '/period/' + periodId
    When method GET
    Then status 404
    And match $.errors[0].message == 'Openings with id \'' + periodId + '\' is not found'

  Scenario: POST calendar period by service point id should return created period and 201 on success
    * def periodId = call uuid1
    * def servicePointId = call uuid1
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

  Scenario: POST calendar period by service point id should return 422 if period is invalid
    * def periodId = call uuid1
    * def servicePointId = call uuid1
    * def createPeriodRequest = read('samples/createPeriodWithNoStartDate.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'must not be null'
    And match $.errors[0].parameters[0].key == 'startDate'

  Scenario: POST calendar period by service point id should return 400 if opening days are empty
    * def periodId = call uuid1
    * def servicePointId = call uuid1
    * def createPeriodRequest = read('samples/createPeriodWithEmptyOpeningDays.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 400
    And match $ contains 'Not valid json object. Missing field(s)'

  Scenario: POST calendar period by service point id should return 400 if service point id is empty
    * def periodId = call uuid1
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
    * def periodId = call uuid1
    * def servicePointIdUrl = call uuid1
    * def periodName = ''
    * def servicePointId = call uuid1
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointIdUrl + '/period'
    And request createPeriodRequest
    When method POST
    Then status 400
    And match $ contains 'Not valid json object. Missing field(s)'

  Scenario: POST calendar period by service point id should return 400 if id is empty
    * def periodId = ''
    * def servicePointIdUrl = call uuid1
    * def periodName = ''
    * def servicePointId = call uuid1
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointIdUrl + '/period'
    And request createPeriodRequest
    When method POST
    Then status 400
    And match $ contains 'Not valid json object. Missing field(s)'

  Scenario: POST calendar period by service point id should return 422 if periods overlap
    * def periodId = call uuid1
    * def servicePointId = call uuid1
    * def periodName = 'Test period1'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    * def periodId = call uuid1
    * def periodName = 'Test period2'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 422
    And match $.errors[0].message == 'The date range entered overlaps with another calendar for this service point. Please correct the date range or enter the hours as exceptions.'

  Scenario: DELETE library hours period by id should return 204 on success
    * def periodId = call uuid1
    * def servicePointId = call uuid1
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
    * def periodId = call uuid1
    * def servicePointId = call uuid1

    Given path 'calendar/periods/' + servicePointId + '/period/' + periodId
    When method DELETE
    Then status 404

  Scenario: PUT library hours period by id should return 204 on success
    * def periodId = call uuid1
    * def servicePointId = call uuid1
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
    * def periodId = call uuid1
    * def servicePointId = call uuid1
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
    * def periodId = call uuid1
    * def servicePointId = call uuid1
    * def periodName = 'Test period1'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    * def periodId = call uuid1
    * def periodName = 'Test period2'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period/' + periodId
    And request createPeriodRequest
    When method PUT
    Then status 422
    And match $.errors[0].message == 'The date range entered overlaps with another calendar for this service point. Please correct the date range or enter the hours as exceptions.'

  Scenario: GET calculated due date for the requested date should return 200 and resulting period
    * def periodId = call uuid1
    * def servicePointId = call uuid1
    * def periodName = 'Test period'
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar/periods/' + servicePointId + '/calculateopening'
    And param requestedDate = '2030-08-13'
    When method GET
    Then status 200
    And match response.openingDays[0].openingDay.date == '2030-08-12T00:00:00.000+00:00'
    And match response.openingDays[0].openingDay.openingHour[0].startTime == '08:00'
    And match response.openingDays[0].openingDay.openingHour[0].endTime == '18:00'
    And match response.openingDays[1].openingDay.date == '2030-08-13T00:00:00.000+00:00'
    And match response.openingDays[1].openingDay.openingHour[0].startTime == '08:00'
    And match response.openingDays[1].openingDay.openingHour[0].endTime == '18:00'
    And match response.openingDays[2].openingDay.date == '2030-08-16T00:00:00.000+00:00'
    And match response.openingDays[2].openingDay.openingHour[0].startTime == '08:00'
    And match response.openingDays[2].openingDay.openingHour[0].endTime == '18:00'

  Scenario: GET calculated due date for the requested date should return 400 if date was malformed
    * def servicePointId = call uuid1

    Given path 'calendar/periods/' + servicePointId + '/calculateopening'
    And param requestedDate = 'malformed date'
    When method GET
    Then status 400