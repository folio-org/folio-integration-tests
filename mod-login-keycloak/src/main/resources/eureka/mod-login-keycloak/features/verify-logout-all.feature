Feature: verify logout-all

  Background:
    * url baseUrl
    * configure cookies = null

  @Positive
  Scenario: verify logout-all invalidates authentication cookies and all refresh tokens for the user
    # Log in twice
    * def firstLogin = call loginWithExpiry
    And match firstLogin.loginStatus == 201
    * def firstRefreshToken = firstLogin.loginResponseCookies.folioRefreshToken.value

    * def secondLogin = call loginWithExpiry
    And match secondLogin.loginStatus == 201
    * def secondRefreshToken = secondLogin.loginResponseCookies.folioRefreshToken.value
    * configure cookies = secondLogin.loginResponseCookies
    * def currentAccessToken = secondLogin.loginResponseCookies.folioAccessToken.value

    # Call logout-all using one authenticated session
    Given path 'authn/logout-all'
    And header x-okapi-tenant = testTenant
    And header x-okapi-token = currentAccessToken
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

    # Verify that the second session's refresh token is also no longer usable.
    Given path 'authn/refresh'
    And header x-okapi-tenant = testTenant
    And cookie folioRefreshToken = secondRefreshToken
    When method post
    Then status 422
    And match response.errors[0].code == 'token.refresh.unprocessable'
