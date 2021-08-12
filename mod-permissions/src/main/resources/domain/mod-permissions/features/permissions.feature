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
    * configure lowerCaseResponseHeaders = true
    * def testUserId = callonce uuid
    * def permissionsUserId = callonce uuid
  #
  # Test permissions operations on users. This is similar to what happens in the browser when a new
  # user is created or when a user's permissions are updated.
  #  

  # This emulates creating a user from scratch via the UI. We need a user without any permissions yet,
  # so the existing test user (the one created in setup-users.feature) won't work because it already has
  # permissions.
  Scenario: Create a test user without any permissions yet
    Given path 'users'
    And headers commonHeaders
    And request
    """
    {
      "id": "#(testUserId)",
      "username": "#(random_string())",
      "active": true
    }
    """
    When method POST
    Then status 201

  Scenario: Create permissions for a user and check that the permission has been granted
    * def perms = ["okapi.all"]
 
    # Do a preflight request to emulate the browser.
    Given path 'perms/users'
    And headers karate.merge(commonHeaders, optionsHeaders)
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "POST"

    # Add some permissions to the user. This is a one-time operation permitted on a new user.
    Given path 'perms/users'
    And headers commonHeaders
    And request
    """
    {
      "id": "#(permissionsUserId)",
      "userId": "#(testUserId)",
      "permissions": #(perms) 
    }
    """
    When method POST
    Then status 201
    And match response.permissions contains $perms[*].name

    # Get the permission user id and do some schema validation of the response.
    Given path 'perms/users'
    And headers commonHeaders
    And param query = 'userId=="' + testUserId + '"'
    When method GET
    Then status 200
    And match response == { permissionUsers: '#array', totalRecords: '#number', resultInfo: '#object' }
    And match response.permissionUsers[0].id == permissionsUserId

    # Check that the permission has been granted and do some schema validation on the response.
    Given path 'perms/permissions'
    And param query = 'permissionName=="okapi.all"'
    And headers commonHeaders
    When method GET
    Then status 200
    And match response == { permissions: '#array', totalRecords: '#number' }
    And match response.permissions[0].grantedTo contains permissionsUserId

  Scenario: Update permissions for the test user and check the permission is granted
    # Get the permissions for the permissions user. This could be obtained from the response
    # above, but why not test out this route and validate the permissions user schema too.
    Given path 'perms/users/', permissionsUserId
    And headers karate.merge(commonHeaders, optionsHeaders)
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "GET"
  
    Given path 'perms/users/', permissionsUserId
    And headers commonHeaders
    When method GET
    Then status 200
    # Validate response -- the PermissionUser object's schema.
    And match response == 
    """
    {
      "id": "#uuid",
      "userId": "#uuid",
      "permissions": "#array",
      "metadata": "#object"
    }
    """
    * def currentPerms = response.permissions

    # Update the permissions for the given user.
    * def newPerms = ["users.all", "login.all"]
    * def permissionsToUpdate = karate.append(currentPerms, newPerms)
    Given path 'perms/users/', permissionsUserId
    And headers karate.merge(commonHeaders, optionsHeaders)
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "PUT"

    Given path 'perms/users/', permissionsUserId
    And headers commonHeaders
    And request
    """
    {
      "userId": "#(testUserId)",
      "permissions": #(permissionsToUpdate)
    }
    """
    When method PUT
    Then status 200
    And match response.permissions contains $currentPerms[*].name
    And match response.permissions contains $newPerms[*].name

    # Check that the permission user id is present in a permission's grantedTo property now that the
    # user has been granted the permission.
    Given path 'perms/permissions'
    And param query = 'permissionName=="users.all"'
    And headers commonHeaders
    When method GET
    Then status 200
    And match response.permissions[0].grantedTo contains permissionsUserId

Scenario: Get the permissions a user has, add a new permission, and remove one
  Given path 'perms/users/', permissionsUserId, 'permissions'
  And headers karate.merge(commonHeaders, optionsHeaders)
  When method OPTIONS
  Then status 204
  And match header access-control-allow-methods contains "GET"

  Given path 'perms/users/', permissionsUserId, 'permissions'
  And headers commonHeaders
  When method GET
  Then status 200
  And match response == { permissionNames: #array, totalRecords: #number }

  # Add a permission to the user.
  * def permToAdd = "configuration.all"
  Given path 'perms/users/', permissionsUserId, 'permissions'
  And headers karate.merge(commonHeaders, optionsHeaders)
  When method OPTIONS
  Then status 204
  And match header access-control-allow-methods contains "POST"

  Given path 'perms/users/', permissionsUserId, 'permissions'
  And headers commonHeaders
  And request { permissionName: #(permToAdd) }
  When method POST
  Then status 200
  And match response == { permissionName: #string }
  And match response == { permissionName: #(permToAdd) }

  # Check that the permission has been granted.
  Given path 'perms/permissions'
  And param query = 'permissionName=="' + permToAdd + '"'
  And headers commonHeaders
  When method GET
  Then status 200
  And match response.permissions[0].grantedTo contains permissionsUserId

  # And that the user has the permission.
  Given path 'perms/users/', permissionsUserId, 'permissions'
  And headers commonHeaders
  When method GET
  Then status 200
  And match response.permissionNames contains permToAdd

  # Remove the permission.
  Given path 'perms/users/', permissionsUserId, 'permissions', permToAdd
  And headers karate.merge(commonHeaders, optionsHeaders)
  When method OPTIONS
  Then status 204
  And match header access-control-allow-methods contains "DELETE"

  Given path 'perms/users/', permissionsUserId, 'permissions', permToAdd
  And headers commonHeaders
  When method DELETE
  Then status 204

  # Check that it was removed from the permission and the user permission.
  Given path 'perms/users/', permissionsUserId, 'permissions'
  And headers commonHeaders
  When method GET
  Then status 200
  And match response.permissionNames !contains permToAdd

  Given path 'perms/permissions'
  And param query = 'permissionName=="' + permToAdd + '"'
  And headers commonHeaders
  When method GET
  Then status 200
  And match response.permissions[0].grantedTo !contains permissionsUserId

  #
  # Test operations on permissions themselves. This is something that happens in the
  # browser under Settings > Users > Permission sets.
  #

  Scenario: Get a certain number of permissions for the tenant and validate the response
    * def numberToGet = 10
    Given path 'perms/permissions'
    And headers karate.merge(commonHeaders, optionsHeaders)
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "GET"
  
    Given path 'perms/permissions'
    And param length = numberToGet
    And headers commonHeaders
    When method GET
    Then status 200
    And match response == { totalRecords: #number, permissions: '#[numberToGet]' }
    # Do some schema validation. Adding or removing properties to the schema will break this 
    # but I think that is how it should be. Note: not every object seems to have a metadata field
    # so I'm marking that as optional (that's what the double hashtag means in karate).
    And match each response.permissions ==
    """
    {
      "id": "#uuid",
      "permissionName": "#string",
      "displayName": "#string",
      "description": "#string",
      "moduleName": "#string",
      "moduleVersion": "#string",
      "tags": "#array",
      "childOf": "#array",
      "grantedTo": "#array",
      "subPermissions": "#array",
      "dummy": "#boolean",
      "mutable": "#boolean",
      "visible": "#boolean",
      "deprecated": "#boolean",
      "metadata": "##object"
    }
    """

  Scenario: Create a new permssion, add it as a sub permission on another new permission, update it, and delete it
    * def permNameOne = "admins.lol-speak"
    * def permNameTwo = "admins.can-has-cheezeburger"
    * def subPermsOne = ["perms.all", "users.all", "login.all"]

    Given path 'perms/permissions'
    And headers karate.merge(commonHeaders, optionsHeaders)
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "POST"
    
    Given path 'perms/permissions'
    And headers commonHeaders
    And request
    """
    {
      "id": "#(uuid())",
      "permissionName": "#(permNameOne)",
      "displayName": "Admin Special Permissions Number 1",
      "description":"LOL privileges.",
      "subPermissions": #(subPermsOne)
    }
    """
    When method POST
    Then status 201
    And match response.permissionName == permNameOne
    And match response.subPermissions == subPermsOne
    * def firstPermissionId = response.id

    # Add the permission as a sub-permission on another new permission.
    Given path 'perms/permissions'
    And headers karate.merge(commonHeaders, optionsHeaders)
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "POST"
    
    * def subPermsTwo = karate.append(subPermsOne, permNameOne)
    Given path 'perms/permissions'
    And headers commonHeaders
    And request
    """
    {
      "id": "#(uuid())",
      "permissionName": "#(permNameTwo)",
      "displayName": "Can Has Cheezburger",
      "description":"Cheezeburger ability.",
      "subPermissions": #(subPermsTwo)
    }
    """
    When method POST
    Then status 201
    And match response.permissionName == permNameTwo
    And match response.subPermissions == subPermsTwo
    * def secondPermissionId = response.id

    # Grab the permissions by id and verify that they contain the right stuff.
    # These objects are returned in the requests above, but we might as well test out the GET
    # routes for permissions too.
    Given path 'perms/permissions', firstPermissionId
    And headers karate.merge(commonHeaders, optionsHeaders)
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "GET"

    Given path 'perms/permissions', firstPermissionId
    And headers commonHeaders
    When method GET
    Then status 200
    And match response.subPermissions == subPermsOne

    Given path 'perms/permissions', secondPermissionId
    And headers karate.merge(commonHeaders, optionsHeaders)
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "GET"

    Given path 'perms/permissions', secondPermissionId
    And headers commonHeaders
    When method GET
    Then status 200
    And match response.subPermissions == subPermsTwo

    # Update the permission.
    Given path 'perms/permissions', firstPermissionId
    And headers karate.merge(commonHeaders, optionsHeaders)
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "PUT"
    
    * def newDisplayName = "Admin Special Permissions Number 2"
    * def newSubPerms = karate.append(subPermsOne, permNameOne)
    Given path 'perms/permissions', firstPermissionId
    And headers commonHeaders
    And request
    """
    {
      "id": "#(firstPermissionId)",
      "permissionName": "#(permNameOne)",
      "displayName": "#(newDisplayName)",
      "description": "Extra LOL privileges.",
      "subPermissions": #(newSubPerms)
    }
    """
    When method PUT
    Then status 200
    And match response.displayName == newDisplayName
    And match response.subPermissions contains permNameOne

    # Check that the update succeeded.
    Given path 'perms/permissions', firstPermissionId
    And headers commonHeaders
    When method GET
    Then status 200
    And match response.displayName == newDisplayName
    And match response.subPermissions contains permNameOne

    # Delete the first permission and verify the deletion has taken place.
    Given path 'perms/permissions', firstPermissionId
    And headers karate.merge(commonHeaders, optionsHeaders)
    When method OPTIONS
    Then status 204
    And match header access-control-allow-methods contains "DELETE"

    Given path 'perms/permissions', firstPermissionId
    And headers commonHeaders
    When method DELETE
    Then status 204

    Given path 'perms/permissions', firstPermissionId
    And headers commonHeaders
    When method GET
    Then status 404

 
    
 
