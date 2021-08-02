Feature: Test password validate

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    * def password = read('classpath:samples/password.json')

  Scenario: POST validate should return 200 on success
    Given path 'password/validate'
    And request password
    When method POST
    Then status 200

  Scenario: POST validate should return 422 if password contains consecutive whitespaces
    Given path 'password/validate'
    And request password
    And set password.password = "Wrong"
    When method POST
    Then status 422
    And match response.message == "The password must not contain multiple consecutive whitespaces"

  Scenario: POST validate should return 422 if password contains user name
    Given path 'password/validate'
    And request password
    And set password.password = "Wrong"
    When method POST
    Then status 422
    And match response.message == "The password must not contain your username"

  Scenario: POST validate should return 422 if password contains white space characters
    Given path 'password/validate'
    And request password
    And set password.password = "Wrong"
    When method POST
    Then status 422
    And match response.message == "The password must not contain a white space"

  Scenario: POST validate should return 422 if password contains keyboard sequence
    Given path 'password/validate'
    And request password
    And set password.password = "Wrong"
    When method POST
    Then status 422
    And match response.message == "The password must not contain a keyboard sequence"

  Scenario: POST validate should return 422 if password contains repeating characters
    Given path 'password/validate'
    And request password
    And set password.password = "Wrong"
    When method POST
    Then status 422
    And match response.message == "The password must not contain repeating symbols"

  Scenario: POST validate should return 422 if password NOT contains special character
    Given path 'password/validate'
    And request password
    And set password.password = "Wrong"
    When method POST
    Then status 422
    And match response.message == "The password must contain at least one special character"

  Scenario: POST validate should return 422 if password NOT contains numeric symbol
    Given path 'password/validate'
    And request password
    And set password.password = "Wrong"
    When method POST
    Then status 422
    And match response.message == "The password must contain at least one numeric character"

  Scenario: POST validate should return 422 if password NOT contains upper and lower case letters
    Given path 'password/validate'
    And request password
    And set password.password = "Wrong"
    When method POST
    Then status 422
    And match response.message == "The password must contain both upper and lower case letters"

  Scenario: POST validate should return 422 if password length less then 8 characters
    Given path 'password/validate'
    And request password
    And set password.password = "Wrong"
    When method POST
    Then status 422
    And match response.message == "The password length must be at least 8 characters long"
