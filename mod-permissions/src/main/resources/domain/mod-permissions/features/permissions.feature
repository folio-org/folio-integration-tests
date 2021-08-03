Feature: Permissions tests

  Background:
    * url baseUrl
    * call login testAdmin
    * def commonHeaders =
    """
    {
      "x-okapi-tenant": "#(testTenant)",
      "x-okapi-token": "#(okapitoken)",
      "Content-Type": "application/json",
      "Accept": "application/json, text/plain"
    }
    """
    * def optionsHeaders =
    """
    {
      "Access-Control-Allow-Headers": "Content-Type, X-Okapi-Tenant, X-Okapi-Token, Authorization, X-Okapi-Request-Id, X-Okapi-Module-Id",
      "Access-Control-Request-Method": "PUT, PATCH, DELETE, GET, POST",
      "Access-Control-Allow-Origin": "*",
      "Origin": "#(baseUrl)"
    }
    """
    # This is hardcoded in common/setup-users.feature so we're comfortable hardcoding it here.
    * def testUserId = "00000000-1111-5555-9999-999999999992"

  Scenario: Create permissions for the test user
    * print Undefined
    # TODO Create a test user
    # There is a POST route for this

  Scenario: Update permissions for the test user
    # Get the permissions user id for the test user, which is not the same as the user id.
    Given path 'perms/users'
    And headers commonHeaders
    And param query = 'userId=="' + testUserId + '"'
    When method GET
    Then status 200
    * def permissionsUserId = response.permissionUsers[0].id
    * def currentPerms = response.permissionUsers[0].permissions
    * def newPerms = ["perms.all", "users.all", "login.all"]
    * def permissionsToUpdate = karate.append(currentPerms, newPerms)

    # Do a preflight request to emulate the browser.
    Given path 'perms/users/', permissionsUserId
    And headers karate.merge(commonHeaders, optionsHeaders)
    When method OPTIONS
    Then status 204

    # Update the user's permissions.
    Given path 'perms/users/', permissionsUserId
    And headers commonHeaders
    And request
    """
    {
      "userId": #(testUserId),
      "permissions": #(permissionsToUpdate)
    }
    """
    When method PUT
    Then status 200
    And match response.permissions contains $currentPerms[*].name
    And match response.permissions contains $newPerms[*].name
