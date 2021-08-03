Feature: Email

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Get all emails
    Given path 'email'
    When method GET
    Then status 200

  Scenario: Get email should return 500 if internal server error
    Given path 'email'
    And params { lang: '1234', query: 'xxxx' }
    When method GET
    Then status 500

  Scenario: Post email should return 200 on success
    * def requestEntity = read('samples/email-request-entity.json')

    Given path 'email'
    And request requestEntity
    When method POST
    Then status 200

  Scenario: Post email should return 400 if bad request
    * configure headers = { 'x-okapi-token': 'eyJhbGciO.bnQ3MjEwOTc1NTk3OT.nKA7fCCabh3lPcVEQ' }

    Given path 'email'
    And request {}
    When method POST
    Then status 400

  Scenario: Post email should return 422 if request did not pass validation
    Given path 'email'
    And request {}
    When method POST
    Then status 422
