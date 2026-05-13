Feature: CRUD operations on roles users

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: assign, list, update, and delete user roles
    # Create two roles that will be linked to a test user.
    * def firstRoleName = 'karate-roles-users-role-1-' + nowMillis()
    * def secondRoleName = 'karate-roles-users-role-2-' + uuid()
    * def firstRoleId = karate.call('@createRole', { roleName: firstRoleName, roleDescription: 'First role for roles-users Karate tests', roleType: 'REGULAR' }).roleId
    * def secondRoleId = karate.call('@createRole', { roleName: secondRoleName, roleDescription: 'Second role for roles-users Karate tests', roleType: 'REGULAR' }).roleId

    # Create a user to associate with the roles.
    * def userPermission = 'roles.collection.get'
    * def subjectUserName = 'roles-users-user-' + nowMillis()
    * def subjectUser =
      """
      {
        "tenant": "#(testTenant)",
        "name": "#(subjectUserName)",
        "password": "test"
      }
      """
    * def subjectUserPermissions =
      """
      [
        { "name": "#(userPermission)" }
      ]
      """
    * configure headers = null
    * def createUserResult = call read('classpath:common/eureka/create-additional-user.feature') { testUser: #(subjectUser), userPermissions: #(subjectUserPermissions) }
    * def subjectUserId = createUserResult.userId
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

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

  @Positive
  Scenario: deleting a user removes user-role relations
    # Create a role
    * def roleName = 'karate-roles-users-delete-user-role-' + nowMillis()
    * def roleId = karate.call('@createRole', { roleName: roleName, roleDescription: 'Role for user deletion roles-users Karate test', roleType: 'REGULAR' }).roleId

    # Create a user to associate with the role.
    * def userPermission = 'roles.collection.get'
    * def subjectUserName = 'roles-users-delete-user-' + nowMillis()
    * def subjectUser =
      """
      {
        "tenant": "#(testTenant)",
        "name": "#(subjectUserName)",
        "password": "test"
      }
      """
    * def subjectUserPermissions =
      """
      [
        { "name": "#(userPermission)" }
      ]
      """
    * configure headers = null
    * def createUserResult = call read('classpath:common/eureka/create-additional-user.feature') { testUser: #(subjectUser), userPermissions: #(subjectUserPermissions) }
    * def subjectUserId = createUserResult.userId
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = testUserHeaders

    # Assign the role and verify the relation exists before deleting the user.
    * def assignUserRolesRequest =
      """
      {
        "userId": "#(subjectUserId)",
        "roleIds": ["#(roleId)"]
      }
      """
    Given path 'roles', 'users'
    And request assignUserRolesRequest
    When method post
    Then status 201
    And match response.totalRecords == 1
    And match response.userRoles[0] contains deep { userId: '#(subjectUserId)', roleId: '#(roleId)' }

    Given path 'roles', 'users', subjectUserId
    When method get
    Then status 200
    And assert response.userRoles.length == 1
    And match response.userRoles[0] contains deep { userId: '#(subjectUserId)', roleId: '#(roleId)' }

    # Delete the user through mod-users-keycloak.
    * call login testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    Given path 'users-keycloak', 'users', subjectUserId
    When method delete
    Then status 204

    # Verify user-role relations are eventually removed after user deletion.
    * configure headers = testUserHeaders
    * configure retry = { count: 10, interval: 1000 }
    Given path 'roles', 'users', subjectUserId
    And retry until responseStatus == 200 && response.userRoles.length == 0
    When method get
    Then status 200
    And match response.userRoles == []

    # Clean up the created role
    Given path 'roles', roleId
    When method delete
    Then status 204

  @Negative
  Scenario: deleting roles for a user with no assignments returns 404
    * def missingUserId = uuid()
    Given path 'roles', 'users', missingUserId
    When method delete
    Then status 404
    And match response.errors == '#array'

  @ignore @createRole
  Scenario: create role helper
    * def roleRequest =
      """
      {
        "name": "#(roleName)",
        "description": "#(roleDescription)",
        "type": "#(roleType)"
      }
      """
    Given path 'roles'
    And request roleRequest
    When method post
    Then status 201
    And match response.id == '#uuid'
    * def roleId = response.id
