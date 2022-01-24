@parallel=false
Feature: Inn reach location

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
  Scenario: Delete location
    * print 'Delete location'

  @Undefined
  Scenario: Get location by id
    * print 'Get location by id'

  @Undefined
  Scenario: Get locations
    * print 'Get locations'

  @Undefined
  Scenario: Create inn reach location
    * print 'Create inn reach location'

  @Undefined
  Scenario: Update location
    * print 'Update location'
