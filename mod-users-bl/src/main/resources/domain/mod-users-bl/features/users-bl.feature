Feature: Test user business logic

  Background:
    * url baseUrl
    * configure lowerCaseResponseHeaders = true
    * def newPassword = "Passw0rd1;"

  Scenario: Login, validate the response, change password, login with new
    * call login testAdmin
    * configure headers =
    """
    {
      "X-Okapi-Tenant": "#(testTenant)",
      "Accept": "application/json"
    }
    """

    # Login the test user. This user was created in common/setup-users.feature.
    Given path 'bl-users/login'
    And header Origin = baseUrl
    And header Access-Control-Request-Method = "POST"
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "POST"

    Given path 'bl-users/login'
    And request
    """
    {
      "username": "#(testUser.name)",
      "password": "#(testUser.password)"
    }
    """
    When method POST
    Then status 201
    # Grab some variables from the response.
    * def token = responseHeaders['x-okapi-token'][0]
    * def userId = response.user.id
    # Do some validation on the response.
    And match response.user.id == '#uuid'
    And match response.user.username == testUser.name
    And match response.user.active == true
    And match response.permissions.id == '#uuid'
    And match response.permissions.permissions == '#array'

    # Update the user's password.
    Given path 'bl-users/settings/myprofile/password'
    And header Origin = baseUrl
    And header Access-Control-Request-Method = "POST"
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "POST"

    Given path 'bl-users/settings/myprofile/password'
    And header x-okapi-token = token
    And request
    """
    {
      "userId": "#(userId)",
      "username": "#(testUser.name)",
      "password": "#(testUser.password)",
      "newPassword": "#(newPassword)"
    }
    """
    When method POST
    Then status 204

    # Login with the new password.
    Given path 'bl-users/login'
    And request
    """
    {
      "username": "#(testUser.name)",
      "password": "#(newPassword)"
    }
    """
    When method POST
    Then status 201
    And match responseHeaders contains { 'x-okapi-token': '#present' }
