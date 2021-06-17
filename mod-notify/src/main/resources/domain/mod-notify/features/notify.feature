Feature: Notify

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Get all notify entries
    Given path 'notify'
    When method GET
    Then status 200

  @Undefined
  Scenario: POST returns 422 when request validation fails
    * print 'undefined'

  @Undefined
  Scenario: POST returns 422 when ID in request is invalid
    * print 'undefined'

  @Undefined
  Scenario: POST returns 201 when event config name in request is null
    * print 'undefined'

  @Undefined
  Scenario: POST returns 201 when message delivery is successful
    * print 'undefined'

  @Undefined
  Scenario: GET returns 200 on success
    * print 'undefined'

  @Undefined
  Scenario: GET by ID returns 422 when requested ID is invalid
    * print 'undefined'

  @Undefined
  Scenario: GET by ID returns 404 when notification is not found
    * print 'undefined'

  @Undefined
  Scenario: GET by ID returns 200 when notification is found
    * print 'undefined'

  @Undefined
  Scenario: DELETE returns 422 when requested ID is invalid
    * print 'undefined'

  @Undefined
  Scenario: DELETE returns 404 when notification is not found
    * print 'undefined'

  @Undefined
  Scenario: DELETE returns 204 on success
    * print 'undefined'

  Scenario: PUT returns 422 when requested ID is invalid
    * print 'undefined'

  @Undefined
  Scenario: PUT returns 422 when requested requested ID does not match ID in the body
    * print 'undefined'

  @Undefined
  Scenario: PUT returns 422 when recipient ID in the body is empty
    * print 'undefined'

  @Undefined
  Scenario: PUT returns 404 when notification is not found by ID
    * print 'undefined'

  @Undefined
  Scenario: POST by username returns 400 when user is not found
    * print 'undefined'

  @Undefined
  Scenario: POST by username returns 201 on success
    * print 'undefined'

  @Undefined
  Scenario: GET for self returns 200 on success
    * print 'undefined'

  @Undefined
  Scenario: POST for self always returns 500
    * print 'undefined'

  @Undefined
  Scenario: DELETE for self returns 204 on success
    * print 'undefined'

  @Undefined
  Scenario: DELETE for self returns 404 when no notifications are found
    * print 'undefined'