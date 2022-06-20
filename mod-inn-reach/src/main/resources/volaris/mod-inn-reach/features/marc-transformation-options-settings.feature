@parallel=false
Feature: MARC transformation options settings

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)', 'Accept': 'application/json'  }

    * configure headers = headersUser

  @Undefined
  Scenario: Get all MARC transformation options settings
    * print 'Get all MARC transformation options settings'

  @Undefined
  Scenario: Get MARC transformation options settings by id
    * print 'Get MARC transformation options settings by id'

  @Undefined
  Scenario: Create MARC transformation options settings
    * print 'Create MARC transformation options settings'

  @Undefined
  Scenario: Update MARC transformation options settings
    * print 'Update MARC transformation options settings'

  @Undefined
  Scenario: Delete MARC transformation options settings
    * print 'Delete MARC transformation options settings'

