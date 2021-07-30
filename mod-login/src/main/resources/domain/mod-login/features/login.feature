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
        "login.password-reset-action.post"
      ]
    }
    """
    When method POST
    Then status 201

  Scenario: Login user, reset password, change username
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-tenant': #(testTenant), 'Accept': 'application/json, text/plain' }

    # Log in the tester user to get a token.
    Given path 'authn/login'
    And request { username: '#(testerName)', password: '#(testerPassword)' }
    When method POST
    Then status 201
    And match responseHeaders contains { 'x-okapi-token': '#present' }
    * def testerToken = responseHeaders['x-okapi-token'][0]

    #
    # Reset the tester user's password.
    #

    # First generate the action.
    * def actionId = uuid()
    * def expirationTime = getPasswordResetExpiration()
    Given path 'authn/password-reset-action'
    And header x-okapi-token = testerToken
    And request
    """
    {
      "id": "#(actionId)",
      "userId": "#(testerId)",
      "expirationTime": "#(expirationTime)"
    }
    """
    When method POST
    Then status 201

    # Now reset with the action id.
    Given path 'authn/reset-password'
    And header x-okapi-token = testerToken
    And request
    """
    {
      "passwordResetActionId": "#(actionId)",
      "newPassword": "#(testerNewPassword)"
    }
    """
    When method POST
    Then status 201

    # TODO Is the expirationTime a timestamp or should it be when the client wants it to actually expire?
    # TODO Try logging in with the new password.
    # TODO Update the user's username.