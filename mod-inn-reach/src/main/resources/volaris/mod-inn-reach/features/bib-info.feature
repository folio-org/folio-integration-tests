@ignore
@parallel=false
Feature: Bib info

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
  Scenario: Create new Instance Type
    * print 'Create new Instance Type'

  @Undefined
  Scenario: Create new Instance
    * print 'Create new Instance Type'

  @Undefined
  Scenario: Create new Central Server
    * print 'Create new Central Server'

