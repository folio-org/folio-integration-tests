@parallel=false
Feature: Central server configuration

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
  Scenario: Get central server agencies
    * print 'Get central server agencies'

  @Undefined
  Scenario: Get central server item types
    * print 'Get central server item types'

  @Undefined
  Scenario: Get central server patron types
    * print 'Get central server patron types'

