Feature: Test codex packages

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json' }
    * configure headers = headersUser

  @Undefined
  Scenario: Test GET codex-packages
    * print 'undefined'

  @Undefined
  Scenario: Test GET codex-packages should return 400 if malformed query parameter
    * print 'undefined'

  @Undefined
  Scenario: Test GET codex-packages should return 422 if validation error
    * print 'undefined'

  @Undefined
  Scenario: Test GET codex-package by id
    * print 'undefined'

  @Undefined
  Scenario: Test GET codex-packages by id should return 404 if item with given id not found
    * print 'undefined'

  @Undefined
  Scenario: Test GET codex-packages-sources
    * print 'undefined'

  @Undefined
  Scenario: Test GET codex-packages-sources should return 400 if malformed query parameter
    * print 'undefined'
