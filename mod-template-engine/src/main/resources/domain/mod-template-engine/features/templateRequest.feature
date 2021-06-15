Feature: Template processing requests tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  @Undefined
  Scenario: Post templateProcessingRequest should return 422 if request did not pass validation
    * print 'undefined'

  @Undefined
  Scenario: Post templateProcessingRequest should return 200 and templateProcessingResult
    * print 'undefined'

  @Undefined
  Scenario: Post templateProcessingRequest should return 400 if template does not exist
    * print 'undefined'

  @Undefined
  Scenario: Post templateProcessingRequest should return 400 if template does not support requested output format
    * print 'undefined'

  @Undefined
  Scenario: Post templateProcessingRequest should return 400 if template does not have localized template for the specified language
    * print 'undefined'
