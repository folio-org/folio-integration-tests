Feature: User permissions reflect role capability changes

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: user permissions reflect updated role capabilities
    # Create a role.
    * def roleName = 'karate-role-capability-user-permissions-' + nowMillis()
    * def roleId = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/role-helpers.feature@createRole', ({ roleName: roleName, roleDescription: 'Role for user permission refresh Karate tests', roleType: 'REGULAR' })).roleId

    # Resolve the capabilities corresponding to the predefined permission names.
    * def firstCapabilityPermission = 'role-capabilities.collection.post'
    * def secondCapabilityPermission = 'role-capabilities.collection.get'
    * def baselineCapabilityPermission = 'role-capabilities.collection.put'

    Given path 'capabilities'
    And param query = 'permission=="' + firstCapabilityPermission + '"'
    When method get
    Then status 200
    And match response.capabilities == '#[1]'
    * def firstCapability = response.capabilities[0]

    Given path 'capabilities'
    And param query = 'permission=="' + secondCapabilityPermission + '"'
    When method get
    Then status 200
    And match response.capabilities == '#[1]'
    * def secondCapability = response.capabilities[0]

    Given path 'capabilities'
    And param query = 'permission=="' + baselineCapabilityPermission + '"'
    When method get
    Then status 200
    And match response.capabilities == '#[1]'

    # Assign the initial capability to the role.
    * def assignRoleCapabilitiesRequest =
      """
      {
        "roleId": "#(roleId)",
        "capabilityIds": ["#(firstCapability.id)"]
      }
      """
    Given path 'roles', 'capabilities'
    And request assignRoleCapabilitiesRequest
    When method post
    Then status 201
    And match response.totalRecords == 1

    # Create a user with one baseline permission.
    * def subjectUserName = 'role-capability-permissions-user-' + nowMillis()
    * def subjectUserPermissions = ([{ name: baselineCapabilityPermission }])
    * def createUserResult = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/user-helpers.feature@createAdditionalUser', ({ userName: subjectUserName, userPermissions: subjectUserPermissions }))
    * def subjectUserId = createUserResult.userId

    # Assign the role to the new user.
    * def assignUserRoleRequest =
      """
      {
        "userId": "#(subjectUserId)",
        "roleIds": ["#(roleId)"]
      }
      """
    Given path 'roles', 'users'
    And request assignUserRoleRequest
    When method post
    Then status 201

    # Verify user has baseline direct permission and the initial role permission.
    Given path 'permissions', 'users', subjectUserId
    When method get
    Then status 200
    And match response.userId == subjectUserId
    And assert response.permissions.length >= 2
    And match response.permissions contains baselineCapabilityPermission
    And match response.permissions contains firstCapabilityPermission
    And assert response.permissions.indexOf(secondCapabilityPermission) == -1

    # Update the role so the user should receive a different permission.
    * def updateRoleCapabilitiesRequest =
      """
      {
        "capabilityNames": ["#(secondCapability.name)"]
      }
      """
    Given path 'roles', roleId, 'capabilities'
    And request updateRoleCapabilitiesRequest
    When method put
    Then status 204

    # Verify the user's permission reflects the role change.
    Given path 'permissions', 'users', subjectUserId
    When method get
    Then status 200
    And match response.userId == subjectUserId
    And assert response.permissions.length >= 2
    And match response.permissions contains baselineCapabilityPermission
    And match response.permissions contains secondCapabilityPermission
    And assert response.permissions.indexOf(firstCapabilityPermission) == -1

    # Clean up the role after the verification.
    Given path 'roles', roleId
    When method delete
    Then status 204
