@ignore
@parallel=false
Feature: Patron info

  Background:
    * url baseUrl
    * callonce login testAdmin
    * def okapitokenAdmin = okapitoken

    * callonce login testUser
    * def okapitokenUser = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenUser)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json'  }
    * def headersAdmin = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitokenAdmin)',  'x-okapi-tenant': '#(testTenant)','Accept': 'application/json'  }

    * configure headers = headersUser

  @Undefined
  Scenario: Verify patron
    * print 'Verify patron'
