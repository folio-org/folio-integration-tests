Feature: Proxy

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/vnd.api+json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/vnd.api+json' }

  @Undefined
  Scenario: GET proxy types with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET proxy types by KB credentials id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET root proxy with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET root proxy by KB credentials id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: PUT root proxy by KB credentials id with 200 on success
    * print 'undefined'

  @Undefined
  Scenario: PUT root proxy by KB credentials id should return 422 if required attribute is missing
    * print 'undefined'
