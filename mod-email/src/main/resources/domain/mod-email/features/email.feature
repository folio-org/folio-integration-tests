Feature: Email

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Get all emails
    Given path 'email'
    When method GET
    Then status 200

  @Undefined
  Scenario: Get email should return 401 if unauthorized error
    * print 'undefined'

  @Undefined
  Scenario: Get email should return 404 if email is not found
    * print 'undefined'

  @Undefined
  Scenario: Get email should return 500 if internal server error
    * print 'undefined'

  @Undefined
  Scenario: Post email should return 200 on success
    * print 'undefined'

  @Undefined
  Scenario: Post email should return 400 if bad request
    * print 'undefined'

  @Undefined
  Scenario: Post email should return 500 if internal server error
    * print 'undefined'
