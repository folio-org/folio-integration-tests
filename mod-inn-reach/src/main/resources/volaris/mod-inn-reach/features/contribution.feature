@ignore
@parallel=false
Feature: Contribution

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
  Scenario: Get current contribution by server id
    * print 'Get current contribution by server id'

  @Undefined
  Scenario: Get contribution history by server id
    * print 'Get contribution history by server id'

  @Undefined
  Scenario: Start initial contribution
    * print 'Start initial contribution'
