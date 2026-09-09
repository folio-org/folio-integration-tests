Feature: self

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserId = karate.get('userId')
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)', 'x-okapi-user-id': '#(testUserId)' }

  @Negative
  Scenario: unauthenticated request to _self returns 401
    Given path 'users-keycloak', '_self'
    And header x-okapi-tenant = testTenant
    When method get
    Then status 401

  @Positive
  Scenario: authenticated request to _self returns current user
    * configure headers = testUserHeaders
    Given path 'users-keycloak', '_self'
    When method get
    Then status 200
    * match response.user != null
    * match response.user.active == true
