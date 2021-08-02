Feature: Test password validate

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiToken)', 'Accept': 'application/json'  }

  @Undefined
  Scenario: Post validate should return 200 on success
    * print 'undefined'

  @Undefined
  Scenario: POST password should return 422 if validation error
    * print 'undefined'

  @Undefined
  Scenario: POST password should return 400 if bad request
    * print 'undefined'

  @Undefined
  Scenario: POST password should return 500 if internal server error
    * print 'undefined'
