@parallel=false
Feature: Inn reach transaction

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
  Scenario: Get inn reach transaction
    * print 'Get inn reach transaction'

  @Undefined
  Scenario: Check in patron hold item
    * print 'Check in patron hold item'

  @Undefined
  Scenario: Check out item hold item
    * print 'Check out item hold item'

  @Undefined
  Scenario: Get all transactions
    * print 'Get all transactions'
