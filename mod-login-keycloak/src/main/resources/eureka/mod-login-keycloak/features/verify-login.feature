Feature: verify login

  Background:
    * url baseUrl

  @Positive
  Scenario: verify login-with-expiry returns a valid token
    Given path 'authn/login-with-expiry'
    And header Content-Type = 'application/json'
    And header x-okapi-tenant = testTenant
    And request { username: '#(testUser.name)', password: '#(testUser.password)' }
    When method post
    Then status 201
    And match responseCookies.folioAccessToken == '#present'
