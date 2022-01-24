@parallel=false
Feature: Central server

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
  Scenario: Delete central server
    * print 'Delete central server'

  @Undefined
  Scenario: Get central server by id
    * print 'Get central server by id'

  @Undefined
  Scenario: Get central servers
    * print 'Get central servers'

  @Undefined
  Scenario: Create central server
    * print 'Create central server'

  @Undefined
  Scenario: Update central server
    * print 'Update central server'

