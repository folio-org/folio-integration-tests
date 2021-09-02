Feature: Packages

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }

  @Undefined
  Scenario: Get all Packages
    * print 'undefined'

  @Undefined
  Scenario: GET all Packages filtered by custom with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all Packages filtered by selected with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all Packages filtered by tags with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all Packages filtered by access-type with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET all Packages should return 400 if filter parameter is invalid
    * print 'undefined'

  @Undefined
  Scenario: POST Packages should create a custom package with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: POST Packages should return 400 if Package with the provided name already exists
    * print 'undefined'

  @Undefined
  Scenario: POST Packages should return 422 if name is invalid
    * print 'undefined'

  @Undefined
  Scenario: GET Package by id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET Package by id should return 400 if Package or provider id are invalid
    * print 'undefined'

  @Undefined
  Scenario: GET Package by id should return 404 if Package not found
    * print 'undefined'

  @Undefined
  Scenario: PUT Package by id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: PUT Package by id should return 400 if Attribute is missing
    * print 'undefined'

  @Undefined
  Scenario: PUT Package by id should return 404 if Vendor not found
    * print 'undefined'

  @Undefined
  Scenario: PUT Package by id should return 422 if Coverage is invalid
    * print 'undefined'

  @Undefined
  Scenario: DELETE Package by id with 204 on success
    * print 'undefined'

  @Undefined
  Scenario: DELETE Package by id should return 400 if Package is invalid
    * print 'undefined'

  @Undefined
  Scenario: GET Resources by Package id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: PUT Tags assigned to Provider by id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: PUT Tags assigned to Provider by id should return 422 if name is invalid
    * print 'undefined'

  @Undefined
  Scenario: POST Fetch packages in bulk with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: POST Fetch packages in bulk should return 422 if id format is invalid
    * print 'undefined'
