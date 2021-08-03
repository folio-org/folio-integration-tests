Feature: Test POST password validate

  Background:
    * url baseUrl
    * callonce login testUser

    * def okapiUserToken = okapitoken
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiToken)', 'Accept': 'application/json'  }

  @Undefined
  Scenario: Should return valid result
    * print 'undefined'

  @Undefined
  Scenario: Should return invalid result if password contains consecutive whitespaces
    * print 'undefined'

  @Undefined
  Scenario: Should return invalid result if password contains user name
    * print 'undefined'

  @Undefined
  Scenario: Should return invalid result if password contains white space characters
    * print 'undefined'

  @Undefined
  Scenario: Should return invalid result if password contains keyboard sequence
    * print 'undefined'

  @Undefined
  Scenario: Should return invalid result if password contains repeating characters
    * print 'undefined'

  @Undefined
  Scenario: Should return invalid result if password NOT contains special character
    * print 'undefined'

  @Undefined
  Scenario: Should return invalid result if password NOT contains numeric symbol
    * print 'undefined'

  @Undefined
  Scenario: Should return invalid result if password NOT contains upper and lower case letters
    * print 'undefined'

  @Undefined
  Scenario: Should return invalid result if password length less then 8 characters
    * print 'undefined'
