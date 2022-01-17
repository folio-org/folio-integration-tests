@parallel=false
Feature: Contribution criteria

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
   Scenario: Get criteria by server id
    * print 'Get criteria by server id'

  @Undefined
  Scenario: Create contribution criteria
    * print 'Create contribution criteria'

  @Undefined
  Scenario: Update criteria
    * print 'Update criteria'

  @Undefined
  Scenario: Delete criteria
    * print 'Delete  criteria'
