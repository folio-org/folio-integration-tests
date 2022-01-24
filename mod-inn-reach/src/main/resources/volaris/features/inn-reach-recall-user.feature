@parallel=false
Feature: Inn reach recall user

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
  Scenario: Get central server recall user
    * print 'Get central server recall user'

  @Undefined
  Scenario: Save inn reach recall user
    * print 'Save inn reach recall user'

  @Undefined
  Scenario: Update central server recall user
    * print 'Update central server recall user'

