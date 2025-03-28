Feature: refresh token

  Background:
    * url baseUrl
    * configure cookies = null

  Scenario: refrash token
    Given path 'authn', 'refresh'
    And header Accept = 'application/json'
    And header x-okapi-tenant = testTenant
    And cookie folioRefreshToken = refreshToken
    When method POST
    Then status 201
    * def okapitoken = responseCookies['folioAccessToken'].value
    * def refreshToken = responseCookies['folioRefreshToken'].value
    * configure cookies = null
