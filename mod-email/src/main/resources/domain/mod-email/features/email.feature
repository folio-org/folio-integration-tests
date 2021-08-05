Feature: Email

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Get all emails
    Given path 'email'
    When method GET
    Then status 200
    And match response == { emailEntity: #present, totalRecords: #present }

  Scenario: Get email should return 500 if internal server error
    Given path 'email'
    And params { lang: '1234', query: 'xxxx' }
    When method GET
    Then status 500
    And match response == 'Internal Server Error'

  Scenario: Post email should return 200 on success
    * def requestEntity = read('samples/email-request-entity.json')
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-url': '#(baseUrl)', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * def expectedErrMsg = 'The \'mod-config\' module doesn\'t have a minimum config for SMTP server, the min config is: [EMAIL_SMTP_PORT, EMAIL_PASSWORD, EMAIL_SMTP_HOST, EMAIL_USERNAME]'

    Given path 'email'
    And request requestEntity
    When method POST
    Then status 200
    And match response == expectedErrMsg

  Scenario: Post email should return 400 if bad request
    * configure headers = { 'x-okapi-token': 'eyJhbGciO.bnQ3MjEwOTc1NTk3OT.nKA7fCCabh3lPcVEQ' }

    Given path 'email'
    And request {}
    When method POST
    Then status 400
    And match response contains 'Invalid Token: Failed to decode:Unrecognized token'

  Scenario: Post email should return 422 if request did not pass validation
    * def values = { key: ['body', 'to', 'notificationId', 'header'] }

    Given path 'email'
    And request {}
    When method POST
    Then status 422
    And match $.errors[0].message == 'must not be null'
    And match values.key contains any $.errors[0].parameters[0].key
    And match values.key contains any $.errors[1].parameters[0].key
    And match values.key contains any $.errors[2].parameters[0].key
    And match values.key contains any $.errors[3].parameters[0].key
