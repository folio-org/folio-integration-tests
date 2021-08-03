Feature: Test login

  Background:
    * url baseUrl
    * def testerId = uuid()
    * def testerName = "tester01"
    * def testerPassword = "passw0rd1"
    * def testerNewPassword = "passw0rd2"

  # NOTE It's good to do this again even though we already did similar operations in common/setup-users.feature.
  # The reason is that now we're doing it after enabling mod-authtoken for a more real-life scenario.
  Scenario: Create user as admin user, give that user login credentials
    * call login testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-tenant': #(testTenant), 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    # Create the tester user.
    Given path 'users'
    And request
    """
    {
      "id": "#(testerId)",
      "username": "#(testerName)",
      "active": true
    }
    """
    When method POST
    Then status 201
    And match response.id == testerId
    And match response.username == testerName
    And match response.active == true

    # Give the tester user credentials.
    Given path 'authn/credentials'
    And request
    """
    {
      "username": "#(testerName)",
      "password": "#(testerPassword)"
    }
    """
    When method POST
    Then status 201

    # Add some permissions to our tester user to allow for the stuff we want to do.
    Given path 'perms/users'
    And request
    """
    {
      "userId": "#(testerId)",
      "permissions": [
        "login.password-reset.post",
        "login.password-reset-action.post",
        "users-bl.password-reset-link.reset"
      ]
    }
    """
    When method POST
    Then status 201

  Scenario: Login user, reset password, login with new password, change username, login with new username
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-tenant': #(testTenant), 'Accept': 'application/json, text/plain' }

#    # Log in the tester user to get a token.
    Given path 'authn/login'
    And request { username: '#(testerName)', password: '#(testerPassword)' }
    When method POST
    Then status 201
    And match responseHeaders contains { 'x-okapi-token': '#present' }
    * def testerToken = responseHeaders['x-okapi-token'][0]

# TODO This commented out code works, however it's not called by any UI endpoints directly so therefore may not
  # be a good candidate for integration tests. Instead it is invoked by mod-users-bl.
#
#    #
#    # Reset the tester user's password.
#    #
#
#    # First generate the action.
#    * def actionId = uuid()
#    * def expirationTime = getPasswordResetExpiration()
#    Given path 'authn/password-reset-action'
#    And header x-okapi-token = testerToken
#    And request
#    """
#    {
#      "id": "#(actionId)",
#      "userId": "#(testerId)",
#      "expirationTime": "#(expirationTime)"
#    }
#    """
#    When method POST
#    Then status 201
#
#    # Now reset with the action id.
#    Given path 'authn/reset-password'
#    And header x-okapi-token = testerToken
#    And request
#    """
#    {
#      "passwordResetActionId": "#(actionId)",
#      "newPassword": "#(testerNewPassword)"
#    }
#    """
#    When method POST
#    Then status 201
#    And match response == { isNewPassword: true }

    # Try resetting with the mod-users-bl endpoint. This should work but it's not a CP endpoint.
    Given path 'bl-users/password-reset/reset'
    # TODO This fails with an invalid token. A regular okapi token won't work. See how this token is
    # generated in ModUsersResetLinkSvcImpl.java in mod-users-bl line 134.
    And header x-okapi-token = testerToken
    And request { newPassword: '#(testerNewPassword)' }
    When method POST
    Then status 204

    # Login in with the new password.
    Given path 'authn/login'
    And header Authtoken-Refresh-Cache = "true"
    #And request { username: '#(testerName)', password: '#(testerPassword)' }
    # TODO This isn't working with stuff that is commented out ^^. Says password doesn't match.
    And request { username: '#(testerName)', password: '#(testerNewPassword)' }
    When method POST
    Then status 201
    And match responseHeaders contains { 'x-okapi-token': '#present' }
    * def tokenAfterPasswordChange = responseHeaders['x-okapi-token'][0]

    # TODO Is the expirationTime a timestamp or should it be when the client wants it to actually expire?
    # TODO Update the user's username.
    # TODO How exactly does the UI reset the user's password? Does it use the update route instead of the reset route?
    # TODO What code executes on the reset-password route?
