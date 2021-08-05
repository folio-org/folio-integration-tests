Feature: Calendar periods

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Get all periods
    Given path 'calendar', 'periods'
    When method GET
    Then status 200

  Scenario: GET all periods filtered by service point with 200 on success
    * def periodId = call uuid1
    * def servicePointId = call uuid1
#    * def createServicePointRequest = read('samples/createServicePoint.json')
    * def createPeriodRequest = read('samples/createPeriod.json')

#    Given path 'service-points'
#    And request createServicePointRequest
#    When method POST
#    Then status 201

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
    * def createServicePointRequest = read('samples/createServicePoint.json')
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar/periods'
    And param startDate = '2021-08-01'
    When method GET
    Then status 200
#    And match $.openingPeriods[0].name == createPeriodRequest.name

  Scenario: GET all periods filtered by end date with 200 on success
    * def periodId = call uuid1
    * def servicePointId = call uuid1
    * def createServicePointRequest = read('samples/createServicePoint.json')
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar/periods'
    And param endDate = '2021-08-31'
    When method GET
    Then status 200

  @Undefined
  Scenario: GET all periods including closed hours with 200 on success
    * print 'undefined'

  Scenario: GET all periods including exceptional hours with 200 on success
    * def periodId = call uuid1
    * def exceptionPeriodId = call uuid1
    * def servicePointId = call uuid1
    * def createServicePointRequest = read('samples/createServicePoint.json')
    * def createPeriodRequest = read('samples/createPeriod.json')
    * def createExceptionRequest = read('samples/createException.json')
    * def exceptionPeriod = read('samples/exceptionPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createExceptionRequest
    When method POST
    Then status 201

    Given path 'calendar/periods'
    When method GET
    Then status 200
#    And match $. contains deep exceptionPeriod

  Scenario: GET library hours period for service point with 200 on success
    * def servicePointId = call uuid1

    Given path 'calendar/periods/' + servicePointId + '/period'
    When method GET
    Then status 200

  Scenario: GET library hours period for service point with opening days and 200 on success
    * def periodId = call uuid1
    * def servicePointId = call uuid1
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

  @Undefined
  Scenario: GET library hours period for service point including past openings and with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET library hours period for service point with exceptional hours and 200 on success
    * print 'undefined'

  Scenario: GET opening hours for given periodId with 200 on success
    * def periodId = call uuid1
    * def servicePointId = call uuid1
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
    * def createPeriodRequest = read('samples/createPeriod.json')

    Given path 'calendar/periods/' + servicePointId + '/period'
    And request createPeriodRequest
    When method POST
    Then status 201
#    And match $ == createPeriodRequest

  @Undefined
  Scenario: POST calendar period by service point id should return 422 if period is invalid
    * print 'undefined'

  @Undefined
  Scenario: POST calendar period by service point id should return 400 if opening days are empty
    * print 'undefined'

  @Undefined
  Scenario: POST calendar period by service point id should return 400 if service point id is empty
    * print 'undefined'

  @Undefined
  Scenario: POST calendar period by service point id should return 400 if name is empty
    * print 'undefined'

  @Undefined
  Scenario: POST calendar period by service point id should return 400 if id is empty
    * print 'undefined'

  @Undefined
  Scenario: POST calendar period by service point id should return 422 if periods overlap
    * print 'undefined'

  @Undefined
  Scenario: POST calendar period by service point id should return 400 if opening days are empty
    * print 'undefined'

  @Undefined
  Scenario: DELETE library hours period by id should return 204 on success
    * print 'undefined'

  @Undefined
  Scenario: DELETE library hours period by id should return 404 if openings do not exist
    * print 'undefined'

  @Undefined
  Scenario: PUT library hours period by id should return 204 on success
    * print 'undefined'

  @Undefined
  Scenario: PUT library hours period by id should return 422 if period is invalid
    * print 'undefined'

  @Undefined
  Scenario: PUT library hours period by id should return 422 if periods overlap
    * print 'undefined'

  @Undefined
  Scenario: GET calculated due date for the requested date should return 200 and resulting period
    * print 'undefined'

  @Undefined
  Scenario: GET calculated due date for the requested date should return 400 if date was malformed
    * print 'undefined'