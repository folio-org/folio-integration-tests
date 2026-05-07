Feature: verify login with expiry

  Background:
    * url baseUrl

  @Positive
  Scenario: verify login with expiry returns tokens and expiration metadata
    * def loginResponse = call loginWithExpiry
    And match loginResponse.loginStatus == 201
    And match loginResponse.loginResponseBody contains { accessTokenExpiration: '#present', refreshTokenExpiration: '#present' }
    And match loginResponse.loginResponseCookies contains { folioAccessToken: '#present', folioRefreshToken: '#present' }

  @Negative
  Scenario: verify login with expiry rejects a wrong password
    * def loginResponse = call loginWithExpiry { username: '#(testUser.name)', password: 'wrong-password' }
    And match loginResponse.loginStatus == 401
    And match loginResponse.loginResponseCookies == { folioAccessToken: '#notpresent', folioRefreshToken: '#notpresent' }

  @Negative
  Scenario: verify login with expiry rejects an unknown username
    * def loginResponse = call loginWithExpiry { username: 'unknown-user', password: '#(testUser.password)' }
    And match loginResponse.loginStatus == 401
    And match loginResponse.loginResponseCookies == { folioAccessToken: '#notpresent', folioRefreshToken: '#notpresent' }
