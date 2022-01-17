Feature: Configure permissions for admin

  Background:
    * url baseUrl
    * call login testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-tenant': #(testTenant), 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

    * table blUserPermissions
      | name                                |
      | 'users-bl.item.get'                 |
      | 'users-bl.transactions.get'         |
      | 'users-bl.item.delete'              |

    * def testAdminUserId = "00000000-1111-5555-9999-999999999991"

  Scenario: Add bl-users permissions to admin user
    # Get the current perms for the admin user.
    Given path 'perms/users'
    And param query = 'userId=="' + testAdminUserId + '"'
    When method GET
    Then status 200
    # Get the permissions user id.
    * def adminPermissionsUserId = response.permissionUsers[0].id
    * def currentPerms = response.permissionUsers[0].permissions
    * def newPerms = $blUserPermissions[*].name
    * def permissions = karate.append(currentPerms, newPerms)
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
    And match response.permissions contains $blUserPermissions[*].name