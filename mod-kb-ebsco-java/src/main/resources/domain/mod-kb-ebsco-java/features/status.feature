Feature: Status

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json, 'x-okapi-token': '#(okapitoken)' }

  @Undefined
  Scenario: GET status of currently set KB configuration with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET current status of load holdings job with 200 on success
    * print 'undefined'
