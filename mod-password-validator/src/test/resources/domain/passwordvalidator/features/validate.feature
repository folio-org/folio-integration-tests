Feature: Test password validate

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiToken)', 'Accept': 'application/json'  }

  @Undefined
  Scenario: POST validate should return 200 on success
    * print 'undefined'

  @Undefined
  Scenario: POST validate should return 422 if password contains consecutive whitespaces
    * print 'undefined'

  @Undefined
  Scenario: POST validate should return 422 if password contains user name
    * print 'undefined'

  @Undefined
  Scenario: POST validate should return 422 if password contains white space characters
    * print 'undefined'

  @Undefined
  Scenario: POST validate should return 422 if password contains keyboard sequence
    * print 'undefined'

  @Undefined
  Scenario: POST validate should return 422 if password contains repeating characters
    * print 'undefined'

  @Undefined
  Scenario: POST validate should return 422 if password NOT contains special character
    * print 'undefined'

  @Undefined
  Scenario: POST validate should return 422 if password NOT contains numeric symbol
    * print 'undefined'

  @Undefined
  Scenario: POST validate should return 422 if password NOT contains upper and lower case letters
    * print 'undefined'

  @Undefined
  Scenario: POST validate should return 422 if password length less then 8 characters
    * print 'undefined'

  @Undefined
  Scenario: POST password should return 400 if bad request
    * print 'undefined'
