Feature: Delayed tasks

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)','Accept': 'application/json, text/plain' }

  Scenario: Delete should return 204 on success
    Given path 'delayedTask/expiredMessages'
    When method DELETE
    Then status 204

  Scenario: Delete should return 401 if authorization token is invalid
    * configure headers = {'x-okapi-tenant': '#(testTenant)', 'x-okapi-token': 'eyJhbGciO.bnQ3MjEwOTc1NTk3OT.nKA7fCCabh3lPcVEQ' }

    Given path 'delayedTask/expiredMessages'
    When method DELETE
    Then status 401
    And match response.errors[0].type == 'UnauthorizedException'
    And match response.errors[0].code == 'authorization_error'
    And match response.errors[0].message == 'Unauthorized'
  Scenario: Delete should return 500 if internal server error
    Given path 'delayedTask/expiredMessages'
    And param expirationDate = 'incorrect data format'
    When method DELETE
    Then status 500
    And match response == 'Internal Server Error'
