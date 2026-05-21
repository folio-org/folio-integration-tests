Feature: verify token refresh

  Background:
    * url baseUrl
    * configure cookies = null

  @Positive
  Scenario: verify refresh returns a renewed session and expires the old refresh token
    # Log in first so the scenario starts with a valid refresh token.
    * def loginResponse = call loginWithExpiry
    And match loginResponse.loginStatus == 201
    * def originalRefreshToken = loginResponse.loginResponseCookies.folioRefreshToken.value

    # Refresh the session using the original refresh token.
    Given path 'authn/refresh'
    And header x-okapi-tenant = testTenant
    And cookie folioRefreshToken = originalRefreshToken
    When method post
    Then status 201
    And match response contains { accessTokenExpiration: '#present', refreshTokenExpiration: '#present' }
    And match responseCookies.folioAccessToken == '#present'
    And match responseCookies.folioRefreshToken == '#present'
    * def rotatedRefreshToken = responseCookies.folioRefreshToken.value
    * assert originalRefreshToken != rotatedRefreshToken

    * configure cookies = null

    # The original refresh token should be invalid after token rotation.
    Given path 'authn/refresh'
    And header x-okapi-tenant = testTenant
    And cookie folioRefreshToken = originalRefreshToken
    When method post
    Then status 422
    And match response.errors[0].code == 'token.refresh.unprocessable'
