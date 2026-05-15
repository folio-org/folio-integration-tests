Feature: User deletion cleanup

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: deleting a user removes user capabilities and policies
    # Create a user with one direct capability assigned during provisioning.
    * def capabilityPermission = 'role-capabilities.collection.delete'
    * def capability = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilityByPermission', ({ capabilityPermission: capabilityPermission })).capability
    * def subjectUserName = 'user-capabilities-delete-user-' + nowMillis()
    * def subjectUserPermissions = ([{ name: capabilityPermission }])
    * def createUserResult = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/user-helpers.feature@createAdditionalUser', ({ userName: subjectUserName, userPermissions: subjectUserPermissions }))
    * def subjectUserId = createUserResult.userId

    # Verify the direct capability and generated user policy exist before deletion.
    Given path 'users', 'capabilities'
    And param query = 'userId=="' + subjectUserId + '"'
    When method get
    Then status 200
    And match response.totalRecords == 1
    And match response.userCapabilities[*].capabilityId contains capability.id

    * def generatedPolicyName = 'Policy for user: ' + subjectUserId
    Given path 'policies'
    And param query = 'name=="' + generatedPolicyName + '"'
    When method get
    Then status 200
    And match response.policies == '#[1]'

    # Delete the user through mod-users-keycloak.
    * call login testAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    Given path 'users-keycloak', 'users', subjectUserId
    When method delete
    Then status 204

    # Verify that user capabilities and policies are removed
    # Retry because user-deletion cleanup is asynchronous.
    * call login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

    * configure retry = { count: 10, interval: 1000 }
    Given path 'users', 'capabilities'
    And param query = 'userId=="' + subjectUserId + '"'
    And retry until responseStatus == 200 && response.totalRecords == 0
    When method get
    Then status 200
    And match response.userCapabilities == []

    Given path 'policies'
    And param query = 'name=="' + generatedPolicyName + '"'
    And retry until responseStatus == 200 && response.totalRecords == 0
    When method get
    Then status 200
    And match response.policies == []

  @Positive
  Scenario: deleting a user removes user-role relations
    # Create a role and a user that will be linked through roles-users.
    * def roleName = 'karate-user-roles-delete-user-role-' + nowMillis()
    * def roleId = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/role-helpers.feature@createRole', ({ roleName: roleName, roleDescription: 'Role for user deletion user-roles Karate test', roleType: 'REGULAR' })).roleId

    * def userPermission = 'roles.collection.get'
    * def subjectUserName = 'user-roles-delete-user-' + nowMillis()
    * def subjectUserPermissions = ([{ name: userPermission }])
    * def createUserResult = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/user-helpers.feature@createAdditionalUser', ({ userName: subjectUserName, userPermissions: subjectUserPermissions }))
    * def subjectUserId = createUserResult.userId

    # Assign the role and confirm the user-role relation exists before deletion.
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
    And assert response.userRoles.length == 1
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

    # Verify that user roles are removed
    # Retry because user-deletion cleanup is asynchronous.
    * call login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

    * configure retry = { count: 10, interval: 1000 }
    Given path 'roles', 'users', subjectUserId
    And retry until responseStatus == 200 && response.userRoles.length == 0
    When method get
    Then status 200
    And match response.userRoles == []

    Given path 'roles', roleId
    When method delete
    Then status 204
