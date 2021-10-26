Feature: Test codex instances

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json' }
    * configure headers = headersUser

  @Undefined
  Scenario: Test GET codex-instances
    * print 'undefined'

  @Undefined
  Scenario: Test GET codex-instances should return 400 if malformed query parameter
    * print 'undefined'

  @Undefined
  Scenario: Test GET codex-instances should return 422 if validation error
    * print 'undefined'

  @Undefined
  Scenario: Test GET codex-instance by id
    * print 'undefined'

  @Undefined
  Scenario: Test GET codex-instance by id should return 404 if item with given id not found
    * print 'undefined'

  @Undefined
  Scenario: Test GET codex-instances-sources
    * print 'undefined'

  @Undefined
  Scenario: Test GET codex-instances-sources should return 400 if malformed query parameter
    * print 'undefined'
