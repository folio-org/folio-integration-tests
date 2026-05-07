Feature: verify reset password flow

  Background:
    * url baseUrl
    * configure cookies = null

  @Positive
  Scenario: verify reset-password consumes only the latest reset action and updates the user's password
    # Create a new user
    * def resetUser = { tenant: '#(testTenant)', name: '#("reset-user-" + uuid())', password: 'InitialPassword123!' }
    * def userPermissions =
    """
    [
      { name: 'login.password-reset-action.post' },
      { name: 'login.password-reset-action.get' },
      { name: 'login.password-reset.post' }
    ]
    """
    * def resetUserSetup = call read('classpath:common/eureka/create-additional-user.feature') { testUser: '#(resetUser)', userPermissions: '#(userPermissions)' }
    * def resetUserId = resetUserSetup.userId
    * def newPassword = 'ResetPassword123!'
    * def firstResetActionExpirationTime = '2099-01-01T00:00:00.000Z'
    * def latestResetActionExpirationTime = '2099-01-02T00:00:00.000Z'
    * def firstResetActionId = uuid()
    * def latestResetActionId = uuid()

    # Login as new user
    * def resetUserLogin = call loginWithExpiry { username: '#(resetUser.name)', password: '#(resetUser.password)' }
    And match resetUserLogin.loginStatus == 201
    * def userToken = resetUserLogin.loginResponseCookies.folioAccessToken.value

    # Create the first reset action.
    Given path 'authn/password-reset-action'
    And headers { 'Content-Type': 'application/json', 'x-okapi-tenant': '#(testTenant)', 'x-okapi-token': '#(userToken)' }
    And request { id: '#(firstResetActionId)', userId: '#(resetUserId)', expirationTime: '#(firstResetActionExpirationTime)' }
    When method post
    Then status 201
    And match response == { passwordExists: true }

    # Create a newer reset action that should replace the first one.
    Given path 'authn/password-reset-action'
    And headers { 'Content-Type': 'application/json', 'x-okapi-tenant': '#(testTenant)', 'x-okapi-token': '#(userToken)' }
    And request { id: '#(latestResetActionId)', userId: '#(resetUserId)', expirationTime: '#(latestResetActionExpirationTime)' }
    When method post
    Then status 201
    And match response == { passwordExists: true }

    # Verify that the first reset action is no longer available.
    Given path 'authn/password-reset-action', firstResetActionId
    And headers { 'x-okapi-tenant': '#(testTenant)', 'x-okapi-token': '#(userToken)' }
    When method get
    Then status 404

    # Verify that only the latest reset action remains active.
    Given path 'authn/password-reset-action', latestResetActionId
    And headers { 'x-okapi-tenant': '#(testTenant)', 'x-okapi-token': '#(userToken)' }
    When method get
    Then status 200
    And match response == { id: '#(latestResetActionId)', userId: '#(resetUserId)', expirationTime: '#(latestResetActionExpirationTime)' }

    # Reset the password by consuming the latest reset action.
    Given path 'authn/reset-password'
    And headers { 'Content-Type': 'application/json', 'x-okapi-tenant': '#(testTenant)', 'x-okapi-token': '#(userToken)' }
    And request { passwordResetActionId: '#(latestResetActionId)', newPassword: '#(newPassword)' }
    When method post
    Then status 201
    And match response == { isNewPassword: false }

    # Verify that the old password no longer works.
    * def oldPasswordLogin = call loginWithExpiry { username: '#(resetUser.name)', password: '#(resetUser.password)' }
    And match oldPasswordLogin.loginStatus == 401

    # Verify that the new password works and capture a new access token.
    * def newPasswordLogin = call loginWithExpiry { username: '#(resetUser.name)', password: '#(newPassword)' }
    And match newPasswordLogin.loginStatus == 201
    * def newPasswordToken = newPasswordLogin.loginResponseCookies.folioAccessToken.value

    # Verify that the consumed reset action can no longer be fetched.
    Given path 'authn/password-reset-action', latestResetActionId
    And headers { 'x-okapi-tenant': '#(testTenant)', 'x-okapi-token': '#(newPasswordToken)' }
    When method get
    Then status 404
