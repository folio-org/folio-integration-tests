# The admin user requires permissions for configuring saml. This is where we set those since this can't be done
# in common/setup-users.feature because we have to delay registering mod-login-saml until after creating the
# permissions there.
Feature: Configure permissions for admin

  Background:
    * url baseUrl
    * call login testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-tenant': #(testTenant), 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }
    * table samlUserPermissions
      | name                                |
      | 'login-saml.configuration.put'      |
      | 'login-saml.regenerate'             |
    * def testAdminUserId = "00000000-1111-5555-9999-999999999991"

  Scenario: Add login-saml permissions to admin user
    # Get the current perms for the admin user.
    Given path 'perms/users'
    And param query = 'userId=="' + testAdminUserId + '"'
    When method GET
    Then status 200
    # Get the permissions user id.
    * def adminPermissionsUserId = response.permissionUsers[0].id
    * def currentPerms = response.permissionUsers[0].permissions
    * def newPerms = $samlUserPermissions[*].name
    # Combine the current permissions for the admin user (setup by setup-users.feature) with the new desired permissions
    # for login-saml.
    * def permissions = karate.append(currentPerms, newPerms)
    # Put the new permissions into the user who will be registering IdP.
    Given path 'perms/users/', adminPermissionsUserId
    And request
    """
    {
      "userId": #(testAdminUserId),
      "permissions": #(permissions)
    }
    """
    When method PUT
    Then status 200
    And match response.permissions contains $samlUserPermissions[*].name