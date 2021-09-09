Feature: Access types

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }

  @Undefined
  Scenario: Get all Access types
    * print 'undefined'

  @Undefined
  Scenario: GET Access type by id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET Access type by id should return 400 if id is invalid
    * print 'undefined'

  @Undefined
  Scenario: GET Access type by id should return 404 if Access type not found
    * print 'undefined'

  @Undefined
  Scenario: GET all Access types by KB credentials id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: POST Access type by KB credentials id with 201 on success
    * print 'undefined'

  @Undefined
  Scenario: POST Access type by KB credentials id should return 400 if Access type is already exists
    * print 'undefined'

  @Undefined
  Scenario: POST Access type by KB credentials id should return 422 if name is more then 75 characters
    * print 'undefined'

  @Undefined
  Scenario: GET Access type by KB credentials id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET Access type by KB credentials id should return 400 if id is invalid
    * print 'undefined'

  @Undefined
  Scenario: GET Access type by KB credentials id should return 404 if Access type not found
    * print 'undefined'

  @Undefined
  Scenario: PUT Access type by KB credentials id with 204 on success
    * print 'undefined'

  @Undefined
  Scenario: PUT Access type by KB credentials id should return 400 if id is invalid
    * print 'undefined'

  @Undefined
  Scenario: PUT Access type by KB credentials id should return 404 if Access type doesn't exist
    * print 'undefined'

  @Undefined
  Scenario: PUT Access type by KB credentials id should return 422 if required attribute is missing
    * print 'undefined'

  @Undefined
  Scenario: DELETE Access type by KB credentials id with 204 on success
    * print 'undefined'

  @Undefined
  Scenario: DELETE Access type by KB credentials id should return 400 if Package is invalid
    * print 'undefined'
