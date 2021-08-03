Feature: Delayed tasks

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Delete should return 204 on success
    Given path 'delayedTask/expiredMessages'
    When method DELETE
    Then status 204

  Scenario: Delete should return 400 if bad request
    * configure headers = { 'x-okapi-token': 'eyJhbGciO.bnQ3MjEwOTc1NTk3OT.nKA7fCCabh3lPcVEQ' }

    Given path 'delayedTask/expiredMessages'
    When method DELETE
    Then status 400

  Scenario: Delete should return 500 if internal server error
    Given path 'delayedTask/expiredMessages'
    And param expirationDate = 'incorrect data format'
    When method DELETE
    Then status 500
