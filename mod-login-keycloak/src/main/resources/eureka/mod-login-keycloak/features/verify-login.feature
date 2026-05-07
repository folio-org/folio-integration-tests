Feature: verify login

  Background:
    * url baseUrl

  @Positive
  Scenario: verify login returns tokens and authentication cookies
    * def loginResponse = call read('classpath:eureka/mod-login-keycloak/features/verify-login.feature@login')
    And match loginResponse.loginStatus == 201
    And match loginResponse.loginResponseBody contains { okapiToken: '#string', refreshToken: '#string' }
    And match loginResponse.loginResponseCookies contains { folioAccessToken: '#present', folioRefreshToken: '#present' }

  @Negative
  Scenario: verify login rejects a wrong password
    * def loginResponse = call read('classpath:eureka/mod-login-keycloak/features/verify-login.feature@login') { username: '#(testUser.name)', password: 'wrong-password' }
    And match loginResponse.loginStatus == 401
    And match loginResponse.loginResponseCookies == { folioAccessToken: '#notpresent', folioRefreshToken: '#notpresent' }

  @Negative
  Scenario: verify login rejects an unknown username
    * def loginResponse = call read('classpath:eureka/mod-login-keycloak/features/verify-login.feature@login') { username: 'unknown-user', password: '#(testUser.password)' }
    And match loginResponse.loginStatus == 401
    And match loginResponse.loginResponseCookies == { folioAccessToken: '#notpresent', folioRefreshToken: '#notpresent' }

  @ignore @login
  Scenario: login helper
    * configure cookies = null
    * def username = karate.get('username', testUser.name)
    * def password = karate.get('password', testUser.password)
    Given path 'authn/login'
    And headers { 'Content-Type': 'application/json', 'x-okapi-tenant': '#(testTenant)' }
    And request { username: '#(username)', password: '#(password)' }
    When method post
    * def loginStatus = responseStatus
    * def loginResponseBody = response
    * def loginResponseCookies = responseCookies
