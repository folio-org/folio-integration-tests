@parallel=false
Feature:  Item contribution options configuration

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
  Scenario: Get item contribution options configuration by id
    * print 'Get item contribution options configuration by id'

  @Undefined
  Scenario: Create item contribution options configuration
    * print 'Create item contribution options configuration'

  @Undefined
  Scenario: Update item contribution options configuration
    * print 'Update item contribution options configuration'
