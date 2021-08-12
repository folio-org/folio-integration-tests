Feature: Test login

  Background:
    * url baseUrl
    * def testerId = uuid()
    * def testerName = "tester01"
    * def testerPassword = "passw0rd1"
    * def testerNewPassword = "passw0rd2"

  # NOTE It's good to do this again even though we already did similar operations in common/setup-users.feature.
  # The reason is that now we're doing it after enabling mod-authtoken for a more real-life scenario.
  # TODO: These routes should be replaced with mod-users-bl routes.
  Scenario: Create test user as admin user, give that user login credentials
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

  Scenario: Other stuff
    * print undefined
