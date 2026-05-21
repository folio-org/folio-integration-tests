Feature: password reset

  Background:
    * url baseUrl
    * def testUserLogin = callonce read('classpath:common/login.feature') testUser
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(testUserLogin.okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = testUserHeaders
    * def extractResetToken =
      """
      function(link) {
        var queryIndex = link.indexOf('?');
        var pathPart = queryIndex >= 0 ? link.substring(0, queryIndex) : link;
        var queryPart = queryIndex >= 0 ? link.substring(queryIndex + 1) : '';

        if (queryPart) {
          var pairs = queryPart.split('&');
          for (var i = 0; i < pairs.length; i++) {
            var pair = pairs[i];
            var pieces = pair.split('=');
            var key = decodeURIComponent(pieces[0]);
            if (key == 'resetToken') {
              return pieces.length > 1 ? decodeURIComponent(pieces[1]) : '';
            }
          }
        }

        return pathPart.substring(pathPart.lastIndexOf('/') + 1);
      }
      """

  @Positive
  Scenario: generate, validate and use password reset link
    # Create a user with password
    * def resetUsername = 'password-reset-' + nowMillis()
    * def oldPassword = 'Bb2!' + nowMillis()
    * def newPassword = 'Aa1!' + nowMillis()
    * def resetUser = { tenant: '#(testTenant)', name: '#(resetUsername)', password: '#(oldPassword)' }
    * def resetUserPermissions = [{ name: 'auth.token.post' }]
    * configure headers = {}
    * def resetUserResponse = call read('classpath:common/eureka/create-additional-user.feature') { testUser: '#(resetUser)', userPermissions: '#(resetUserPermissions)' }
    * configure headers = testUserHeaders
    * def resetUserId = resetUserResponse.userId

    # Verify the user can login
    * def oldPasswordLogin = call read('classpath:common/login.feature') { tenant: '#(testTenant)', name: '#(resetUsername)', password: '#(oldPassword)' }
    * match oldPasswordLogin.okapitoken == '#string'

    # Generate a password reset link for that user
    * configure headers = testUserHeaders
    Given path 'users-keycloak', 'password-reset', 'link'
    And request { userId: '#(resetUserId)' }
    When method post
    Then status 200
    And assert response.link.startsWith(foliioUiUrl)
    And match response.link contains ('tenant=' + testTenant)
    * def resetLink = response.link
    * def resetToken = extractResetToken(resetLink)
    * def resetHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(resetToken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

    # Validate the password reset link
    * configure headers = resetHeaders
    Given path 'users-keycloak', 'password-reset', 'validate'
    When method post
    Then status 204

    # Reset the password
    Given path 'users-keycloak', 'password-reset', 'reset'
    And request { newPassword: '#(newPassword)' }
    When method post
    Then status 204

    # The new password must work
    * configure headers = testUserHeaders
    * def resetUserLogin = call read('classpath:common/login.feature') { tenant: '#(testTenant)', name: '#(resetUsername)', password: '#(newPassword)' }
    * match resetUserLogin.okapitoken == '#string'

    # The old password should not work after reset
    Given path 'authn', 'login-with-expiry'
    And header x-okapi-tenant = testTenant
    And request { username: '#(resetUsername)', password: '#(oldPassword)' }
    When method post
    Then status 401
