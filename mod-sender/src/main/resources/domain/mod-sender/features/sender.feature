Feature: Sender - message delivery

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Should return 422 when body is invalid
    Given path 'message-delivery'
    And request "{}"
    When method POST
    Then status 422

  @Undefined
  Scenario: Should not fail when user contains additional properties
    * print 'undefined'

  @Undefined
  Scenario: Should return no content and send email when request is valid
    * print 'undefined'

  @Undefined
  Scenario: Should return bad request when delivery channel is not supported
    * print 'undefined'
