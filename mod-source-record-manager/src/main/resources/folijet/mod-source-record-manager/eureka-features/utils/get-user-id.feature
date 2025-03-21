Feature: Get user id for tests variables
  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)', 'Accept': 'application/json, text/plain' }

  Scenario: Get userId
    Given path 'users'
    And param query = 'username ==' + testUser.name
    When method GET
    Then status 200
    * def testUserId = response.users[0].id