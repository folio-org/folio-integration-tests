Feature: Event config

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Get all event configs
    Given path 'eventConfig'
    When method GET
    Then status 200

  @Undefined
  Scenario: Get event config by ID
    * print 'undefined'

  @Undefined
  Scenario: Get event configs by name using a query
    * print 'undefined'


  @Undefined
  Scenario: Post event config
    * print 'undefined'

  @Undefined
  Scenario: Post HTML event config
    * print 'undefined'

  @Undefined
  Scenario: Post text event config
    * print 'undefined'

  @Undefined
  Scenario: Put event config
    * print 'undefined'

  @Undefined
  Scenario: Delete event config
    * print 'undefined'

  @Undefined
  Scenario: Should not allow to create configuration with duplicate name
    * print 'undefined'

  @Undefined
  Scenario: Should return nothing when querying configs with the nonexistent name
    * print 'undefined'

  @Undefined
  Scenario: Should return 500 when tenant is invalid
    * print 'undefined'

  @Undefined
  Scenario: Should return 400 when query is invalid
    * print 'undefined'
