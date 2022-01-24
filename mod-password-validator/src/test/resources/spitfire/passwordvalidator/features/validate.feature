Feature: Test POST password validate

  Background:
    * url baseUrl
    * callonce login testUser

    * def okapiUserToken = okapitoken
    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * configure headers = headersUser

    * def testRuleFailure = 'classpath:spitfire/passwordvalidator/test-rule-failure.feature'
    * def password = read('classpath:samples/password.json')

  Scenario: Should return valid result
    Given path 'password/validate'
    And request password
    When method POST
    Then status 200
    And match response.result == "valid"

  Scenario: Should return 404 if user with given id not found
    Given path 'password/validate'
    And request password
    And set password.userId = "WrongId"
    When method POST
    Then status 404

  Scenario: Should return 422 if userId not provided
    Given path 'password/validate'
    And request password
    And remove password.userId
    When method POST
    Then status 422
    And match response.errors[0].message == "userId must not be null"

  Scenario: Should return 422 if password not provided
    Given path 'password/validate'
    And request password
    And remove password.password
    When method POST
    Then status 422
    And match response.errors[0].message == "password must not be null"

  Scenario: Should return invalid result if password contains consecutive whitespaces
    Given call read(testRuleFailure) { rule: 'no_consecutive_whitespaces' }

  Scenario: Should return invalid result if password contains user name
    Given call read(testRuleFailure) { rule: 'no_user_name' }

  Scenario: Should return invalid result if password contains white space characters
    Given call read(testRuleFailure) { rule: 'no_white_space_character' }

  Scenario: Should return invalid result if password contains keyboard sequence
    Given call read(testRuleFailure) { rule: 'keyboard_sequence' }

  Scenario: Should return invalid result if password contains repeating characters
    Given call read(testRuleFailure) { rule: 'repeating_characters' }

  Scenario: Should return invalid result if password NOT contains special character
    Given call read(testRuleFailure) { rule: 'special_character' }

  Scenario: Should return invalid result if password NOT contains numeric symbol
    Given call read(testRuleFailure) { rule: 'numeric_symbol' }

  Scenario: Should return invalid result if password NOT contains upper and lower case letters
    Given call read(testRuleFailure) { rule: 'alphabetical_letters' }

  Scenario: Should return invalid result if password length less then 8 characters
    Given call read(testRuleFailure) { rule: 'password_length' }
