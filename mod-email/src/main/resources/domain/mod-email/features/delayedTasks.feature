Feature: Delayed tasks

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  @Undefined
  Scenario: Delete should return 204 on success
    * print 'undefined'

  @Undefined
  Scenario: Delete should return 400 if bad request
    * print 'undefined'

  @Undefined
  Scenario: Delete should return 500 if internal server error
    * print 'undefined'
