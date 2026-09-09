Feature: self

  Background:
    * url baseUrl
    * callonce login testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Negative
  Scenario: unauthenticated request to _self returns 401
    Given path 'users-keycloak', '_self'
    And header x-okapi-tenant = testTenant
    And header x-okapi-user-id = 'e8f3d8b2-1c4a-4f7e-9b6d-2a5c0e1f3d8a'
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
    * def selfUserId = response.user.id
    * match response.permissions.userId == selfUserId
