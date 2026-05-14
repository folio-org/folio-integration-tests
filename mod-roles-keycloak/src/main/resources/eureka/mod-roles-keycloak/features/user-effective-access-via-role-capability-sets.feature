Feature: User permissions reflect role capability-set changes

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: user permissions reflect updated role capability sets
    # Create a role.
    * def roleName = 'karate-role-capability-set-user-permissions-' + nowMillis()
    * def roleId = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/role-helpers.feature@createRole', ({ roleName: roleName, roleDescription: 'Role for user permission refresh through capability sets Karate tests', roleType: 'REGULAR' })).roleId

    # Resolve the capability sets corresponding to the predefined permission names.
    * def firstCapabilitySetPermission = 'roles.users.all'
    * def secondCapabilitySetPermission = 'role-capability-sets.all'
    * def baselineCapabilityPermission = 'role-capabilities.collection.post'
    * def baselineCapability = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilityByPermission', ({ capabilityPermission: baselineCapabilityPermission })).capability
    * def firstCapabilitySetResult = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilitySetByPermission', ({ capabilitySetPermission: firstCapabilitySetPermission }))
    * def secondCapabilitySetResult = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilitySetByPermission', ({ capabilitySetPermission: secondCapabilitySetPermission }))
    * def firstCapabilitySet = firstCapabilitySetResult.capabilitySet
    * def secondCapabilitySet = secondCapabilitySetResult.capabilitySet
    * def firstCapabilitySetPermissions = firstCapabilitySetResult.permissions
    * def secondCapabilitySetPermissions = secondCapabilitySetResult.permissions
    * def firstOnlyPermissions = karate.filter(firstCapabilitySetPermissions, x => secondCapabilitySetPermissions.indexOf(x) == -1)
    * assert firstOnlyPermissions.length > 0

    # Assign the initial capability set to the role.
    * def assignRoleCapabilitySetsRequest =
      """
      {
        "roleId": "#(roleId)",
        "capabilitySetIds": ["#(firstCapabilitySet.id)"]
      }
      """
    Given path 'roles', 'capability-sets'
    And request assignRoleCapabilitySetsRequest
    When method post
    Then status 201
    And match response.totalRecords == 1

    # Create a user with one baseline permission.
    * def subjectUserName = 'role-capability-set-permissions-user-' + nowMillis()
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
    And match response.permissions contains baselineCapability.permission
    And match response.permissions contains firstCapabilitySetPermissions

    # Update the role so the user should receive permissions from a different capability set.
    * def updateRoleCapabilitySetsRequest =
      """
      {
        "capabilitySetNames": ["#(secondCapabilitySet.name)"]
      }
      """
    Given path 'roles', roleId, 'capability-sets'
    And request updateRoleCapabilitySetsRequest
    When method put
    Then status 204

    # Verify the user's permission reflects the role change.
    Given path 'permissions', 'users', subjectUserId
    When method get
    Then status 200
    And match response.userId == subjectUserId
    And match response.permissions contains baselineCapability.permission
    And match response.permissions contains secondCapabilitySetPermissions
    And match response.permissions !contains firstOnlyPermissions

    # Clean up the role after the verification.
    Given path 'roles', roleId
    When method delete
    Then status 204
