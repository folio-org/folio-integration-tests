@parallel=false
Feature: User custom field mapping

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
  Scenario: Get user custom field mapping
    * print 'Get user custom field mapping'

  @Undefined
  Scenario: Create user custom field mapping
    * print 'Create user custom field mapping'

  @Undefined
  Scenario: Update user custom field mapping
    * print 'Update user custom field mapping'
