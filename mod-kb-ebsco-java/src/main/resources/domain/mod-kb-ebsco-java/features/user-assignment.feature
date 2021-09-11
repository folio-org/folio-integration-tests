Feature: User Assignment

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }

  @Undefined
  Scenario: GET users by KB credentials id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: POST user by KB credentials id with 201 on success
    * print 'undefined'

  @Undefined
  Scenario: POST user by KB credentials id should return 400 if user is already assigned
    * print 'undefined'

  @Undefined
  Scenario: POST user by KB credentials id should return 422 if required attribute is missing
    * print 'undefined'

  @Undefined
  Scenario: PUT user by KB credentials id with 204 on success
    * print 'undefined'

  @Undefined
  Scenario: PUT user by KB credentials id should return 400 if trying to update ID
    * print 'undefined'

  @Undefined
  Scenario: PUT user by KB credentials id should return 404 if user not found
    * print 'undefined'

  @Undefined
  Scenario: PUT user by KB credentials id should return 422 if required attribute is missing
    * print 'undefined'

  @Undefined
  Scenario: DELETE user by KB credentials id with 204 on success
    * print 'undefined'

  @Undefined
  Scenario: DELETE user by KB credentials id should return 400 if id is invalid
    * print 'undefined'

  @Undefined
  Scenario: DELETE user by KB credentials id should return 404 if user not found
    * print 'undefined'
