Feature: read users

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  Scenario: get test user by id
    * def userId = java.lang.System.getProperty('mod-users-keycloak-testUserId')
    Given path 'users-keycloak', 'users', userId
    When method get
    Then status 200
    And match response.id == userId
    And match response.username == testUser.name
