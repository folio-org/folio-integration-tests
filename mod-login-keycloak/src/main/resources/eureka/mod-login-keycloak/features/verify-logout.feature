Feature: verify logout

  Background:
    * url baseUrl
    * configure cookies = null

  @Positive
  Scenario: verify logout invalidates only the current session and leaves another session active
    # Log in twice
    * def firstLogin = call loginWithExpiry
    And match firstLogin.loginStatus == 201
    * def firstRefreshToken = firstLogin.loginResponseCookies.folioRefreshToken.value

    * def secondLogin = call loginWithExpiry
    And match secondLogin.loginStatus == 201
    * def secondRefreshToken = secondLogin.loginResponseCookies.folioRefreshToken.value

    # Call logout using only the first session's authentication cookies.
    * configure cookies = firstLogin.loginResponseCookies
    Given path 'authn/logout'
    And header x-okapi-tenant = testTenant
    When method post
    Then status 204
    And match responseCookies.folioAccessToken.value == ''
    And match responseCookies.folioRefreshToken.value == ''
    And match responseHeaders['Set-Cookie'] contains "#regex .*folioAccessToken=;.*Max-Age=0.*"
    And match responseHeaders['Set-Cookie'] contains "#regex .*folioRefreshToken=;.*Max-Age=0.*"

    * configure cookies = null

    # Verify that the first session's refresh token is no longer usable.
    Given path 'authn/refresh'
    And header x-okapi-tenant = testTenant
    And cookie folioRefreshToken = firstRefreshToken
    When method post
    Then status 422
    And match response.errors[0].code == 'token.refresh.unprocessable'

    # Verify that the second session is still active and can refresh successfully.
    Given path 'authn/refresh'
    And header x-okapi-tenant = testTenant
    And cookie folioRefreshToken = secondRefreshToken
    When method post
    Then status 201
    And match response contains { accessTokenExpiration: '#present', refreshTokenExpiration: '#present' }
    And match responseCookies.folioAccessToken == '#present'
    And match responseCookies.folioRefreshToken == '#present'
