Feature: CRUD operations on user roles

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: assign, list, update, and delete user roles
    # Create two roles that will be linked to a test user.
    * def firstRoleName = 'karate-user-roles-role-1-' + nowMillis()
    * def secondRoleName = 'karate-user-roles-role-2-' + uuid()
    * def firstRoleId = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/role-helpers.feature@createRole', ({ roleName: firstRoleName, roleDescription: 'First role for user-roles Karate tests', roleType: 'REGULAR' })).roleId
    * def secondRoleId = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/role-helpers.feature@createRole', ({ roleName: secondRoleName, roleDescription: 'Second role for user-roles Karate tests', roleType: 'REGULAR' })).roleId

    # Create a user to associate with the roles.
    * def userPermission = 'roles.collection.get'
    * def subjectUserName = 'user-roles-user-' + nowMillis()
    * def subjectUserPermissions = ([{ name: userPermission }])
    * def createUserResult = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/user-helpers.feature@createAdditionalUser', ({ userName: subjectUserName, userPermissions: subjectUserPermissions }))
    * def subjectUserId = createUserResult.userId

    # Assign both roles to the user in a single request.
    * def assignUserRolesRequest =
      """
      {
        "userId": "#(subjectUserId)",
        "roleIds": ["#(firstRoleId)", "#(secondRoleId)"]
      }
      """
    Given path 'roles', 'users'
    And request assignUserRolesRequest
    When method post
    Then status 201
    And assert response.userRoles.length == 2
    And assert response.userRoles.every(userRole => userRole.userId == subjectUserId)
    And match response.userRoles[*].roleId contains firstRoleId
    And match response.userRoles[*].roleId contains secondRoleId

    # Verify the relations can be listed through collection and item endpoints.
    Given path 'roles', 'users'
    And param query = 'userId=="' + subjectUserId + '"'
    When method get
    Then status 200
    And assert response.userRoles.length == 2
    And assert response.userRoles.every(userRole => userRole.userId == subjectUserId)
    And match response.userRoles[*].roleId contains firstRoleId
    And match response.userRoles[*].roleId contains secondRoleId

    Given path 'roles', 'users', subjectUserId
    When method get
    Then status 200
    And assert response.userRoles.length == 2
    And assert response.userRoles.every(userRole => userRole.userId == subjectUserId)
    And match response.userRoles[*].roleId contains firstRoleId
    And match response.userRoles[*].roleId contains secondRoleId

    # Replace the assigned roles with only the second role.
    * def updateUserRolesRequest =
      """
      {
        "userId": "#(subjectUserId)",
        "roleIds": ["#(secondRoleId)"]
      }
      """
    Given path 'roles', 'users', subjectUserId
    And request updateUserRolesRequest
    When method put
    Then status 204

    Given path 'roles', 'users', subjectUserId
    When method get
    Then status 200
    And assert response.userRoles.length == 1
    And match response.userRoles[0] contains deep { userId: '#(subjectUserId)', roleId: '#(secondRoleId)' }

    # Remove all user-role relations.
    Given path 'roles', 'users', subjectUserId
    When method delete
    Then status 204

    Given path 'roles', 'users', subjectUserId
    When method get
    Then status 200
    And assert response.userRoles.length == 0
    And match response.userRoles == []

    # Clean up the created roles.
    Given path 'roles', firstRoleId
    When method delete
    Then status 204

    Given path 'roles', secondRoleId
    When method delete
    Then status 204

  @Negative
  Scenario: deleting user-role relations for a non-existing user returns 404
    * def missingUserId = uuid()
    Given path 'roles', 'users', missingUserId
    When method delete
    Then status 404
    And match response.errors == '#array'
