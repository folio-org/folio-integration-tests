Feature: login

  Background:
    * url baseUrl
    * configure cookies = null

  Scenario: login user
    Given path 'authn/login-with-expiry'
    And header Accept = 'application/json'
    And header x-okapi-tenant = tenant
    And request { username: '#(name)', password: '#(password)' }
    When method POST
    Then status 201
    * def okapitoken = responseCookies['folioAccessToken'].value
    * def refreshToken = responseCookies['folioRefreshToken'].value
    * configure cookies = null

