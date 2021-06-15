Feature: Templates tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Get all templates
    Given path 'templates'
    When method GET
    Then status 200

  # CRUD

  @Undefined
  Scenario: Post should return 201 and new template
    * print 'undefined'

  @Undefined
  Scenario: Post should return 400 if template resolver is not supported
    * print 'undefined'

  @Undefined
  Scenario: Post should return 422 if template did not pass validation
    * print 'undefined'

  @Undefined
  Scenario: Get by id should return 200
    * print 'undefined'

  @Undefined
  Scenario: Get by id should return 404 if template does not exist
    * print 'undefined'

  @Undefined
  Scenario: Put should return 200 and updated template
    * print 'undefined'

  @Undefined
  Scenario: Put should return 400 if template resolver is not supported
    * print 'undefined'

  @Undefined
  Scenario: Put should return 404 if template does not exist
    * print 'undefined'

  @Undefined
  Scenario: Delete should return 204
    * print 'undefined'

  @Undefined
  Scenario: Delete should return 404 if template does not exist
    * print 'undefined'
