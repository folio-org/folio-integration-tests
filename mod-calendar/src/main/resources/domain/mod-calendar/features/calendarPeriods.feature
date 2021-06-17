Feature: Calendar periods

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Get all periods
    Given path 'calendar', 'periods'
    When method GET
    Then status 200

  @Undefined
  Scenario: GET all periods filtered by service point with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all periods filtered by start date with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all periods filtered by end date with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all periods including closed hours with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all periods including exceptional hours with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET library hours period for service point with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET library hours period for service point with opening days and 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET library hours period for service point including past openings and with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET library hours period for service point with exceptional hours and 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET opening hours for given periodId with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET opening hours for given periodId should return 404 if periodId does not exist
    * print 'undefined'

  @Undefined
  Scenario: POST calendar period by service point id should return created period and 201 on success
    * print 'undefined'

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