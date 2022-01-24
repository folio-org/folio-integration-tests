@parallel=false
Feature: Material type mapping

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
  Scenario: Get material type mappings by server id
    * print 'Get material type mappings by server id'

  @Undefined
  Scenario: Get material type mapping by id
    * print 'Get material type mapping by id'

  @Undefined
  Scenario: Create material type mapping
    * print 'Create material type mapping'

  @Undefined
  Scenario: Update material type mappings
    * print 'Update material type mappings'

  @Undefined
  Scenario: Update material type mapping
    * print 'Update material type mapping'

  @Undefined
  Scenario: Delete material type mapping
    * print 'Delete material type mapping'
