Feature: Resources

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }

  @Undefined
  Scenario: POST Resources with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: POST Resources should return 400 if Package and provider id are not provided
    * print 'undefined'

  @Undefined
  Scenario: POST Resources should return 404 if Title not found
    * print 'undefined'

  @Undefined
  Scenario: POST Resources should return 422 if Package id is invalid
    * print 'undefined'

  @Undefined
  Scenario: GET Resource by id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET Resource by id should return 400 if id is invalid
    * print 'undefined'

  @Undefined
  Scenario: GET Resource by id should return 404 if Title not found
    * print 'undefined'

  @Undefined
  Scenario: POST Resource by id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: POST Resource by id should return 400 if Coverage list contain overlapping dates
    * print 'undefined'

  @Undefined
  Scenario: POST Resource by id should return 422 if coverage is invalid
    * print 'undefined'

  @Undefined
  Scenario: DELETE Resource by id with 204 on success
    * print 'undefined'

  @Undefined
  Scenario: DELETE Resource by id should return 400 if Resource is invalid
    * print 'undefined'

  @Undefined
  Scenario: PUT Tags assigned to Resource by id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: PUT Tags assigned to Resource by id should return 422 if name is invalid
    * print 'undefined'

  @Undefined
  Scenario: POST Fetch resources in bulk with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: POST Fetch resources in bulk should return 422 if resources size more than 20
    * print 'undefined'