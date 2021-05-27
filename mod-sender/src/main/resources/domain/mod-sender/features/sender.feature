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