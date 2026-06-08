Feature: login with expiry helper

  Background:
    * url baseUrl
    * configure cookies = null

  Scenario: login with expiry helper
    * def username = karate.get('username', testUser.name)
    * def password = karate.get('password', testUser.password)
    Given path 'authn/login-with-expiry'
    And headers { 'Content-Type': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    And request { username: '#(username)', password: '#(password)' }
    When method post
    * def loginStatus = responseStatus
    * def loginResponseBody = response
    * def loginResponseCookies = responseCookies
