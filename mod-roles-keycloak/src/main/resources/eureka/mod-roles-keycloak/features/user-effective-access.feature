Feature: User effective access resolution

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: user capabilities and effective permissions reflect the assigned capabilites, capability sets & roles
    # Access paths covered by this scenario:
    # user -> capability
    # user -> capability set -> capabilities
    # user -> role -> capability
    # user -> role -> capability set -> capabilities

    # Resolve one capability and one capability set for the user path, and one of each for the role path.
    * def directCapabilityPermission = 'role-capabilities.collection.delete'
    * def userCapabilitySetPermission = 'capabilities.all'
    * def roleCapabilityPermission = 'roles.collection.get'
    * def roleCapabilitySetPermission = 'roles.users.all'

    * def directCapability = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilityByPermission', ({ capabilityPermission: directCapabilityPermission })).capability
    * def userCapabilitySet = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilitySetByPermission', ({ capabilitySetPermission: userCapabilitySetPermission, includeDummy: true }))
    * def userCapabilitySetWithoutDummy = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilitySetByPermission', ({ capabilitySetPermission: userCapabilitySetPermission }))
    * def roleCapability = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilityByPermission', ({ capabilityPermission: roleCapabilityPermission })).capability
    * def roleCapabilitySet = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilitySetByPermission', ({ capabilitySetPermission: roleCapabilitySetPermission }))

    # Create a role that will contribute role capability and role capability set access.
    * def roleName = 'karate-user-effective-access-role-' + nowMillis()
    * def roleId = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/role-helpers.feature@createRole', ({ roleName: roleName, roleDescription: 'Role for effective user access Karate tests', roleType: 'REGULAR' })).roleId

    # Create a user. Assign a capability directly to the user.
    * def subjectUserName = 'user-effective-access-user-' + nowMillis()
    * def subjectUserPermissions = ([{ name: directCapabilityPermission }])
    * def createUserResult = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/user-helpers.feature@createAdditionalUser', ({ userName: subjectUserName, userPermissions: subjectUserPermissions }))
    * def subjectUserId = createUserResult.userId

    # Assign a capability set directly to the user.
    * def assignUserCapabilitySetsRequest = ({ userId: subjectUserId, capabilitySetIds: [userCapabilitySet.capabilitySet.id] })
    Given path 'users', 'capability-sets'
    And request assignUserCapabilitySetsRequest
    When method post
    Then status 201
    And match response.userCapabilitySets[*].capabilitySetId contains userCapabilitySet.capabilitySet.id

    # Assign one direct capability and one capability set to the role.
    * def assignRoleCapabilitiesRequest = ({ roleId: roleId, capabilityIds: [roleCapability.id] })
    Given path 'roles', 'capabilities'
    And request assignRoleCapabilitiesRequest
    When method post
    Then status 201
    And match response.roleCapabilities[*].capabilityId contains roleCapability.id

    * def assignRoleCapabilitySetsRequest = ({ roleId: roleId, capabilitySetIds: [roleCapabilitySet.capabilitySet.id] })
    Given path 'roles', 'capability-sets'
    And request assignRoleCapabilitySetsRequest
    When method post
    Then status 201
    And match response.roleCapabilitySets[*].capabilitySetId contains roleCapabilitySet.capabilitySet.id

    # Assign the role to the user.
    * def assignUserRolesRequest = ({ userId: subjectUserId, roleIds: [roleId] })
    Given path 'roles', 'users'
    And request assignUserRolesRequest
    When method post
    Then status 201
    And match response.userRoles[*].roleId contains roleId

    # Build the expected user-scoped capability ids returned by the user capabilities endpoint.
    * def distinct =
      """
      function(values) {
        var seen = {};
        var result = [];
        for (var i = 0; i < values.length; i++) {
          var value = values[i];
          if (!seen[value]) {
            seen[value] = true;
            result.push(value);
          }
        }
        return result;
      }
      """
    * def expectedExpandedCapabilityIds = distinct(([directCapability.id]).concat(userCapabilitySet.capabilityIds))
    * def expectedDirectCapabilityIds = ([directCapability.id])

    # Build the expected effective permission names across all four assignment paths.
    * def expectedPermissions = distinct([directCapabilityPermission, roleCapabilityPermission].concat(userCapabilitySetWithoutDummy.permissions).concat(roleCapabilitySet.permissions))

    # Verify the direct user capabilities endpoint returns only directly assigned user capabilities when expand=false.
    Given path 'users', subjectUserId, 'capabilities'
    And param expand = false
    And param includeDummy = true
    And param limit = 50
    When method get
    Then status 200
    And match response.capabilities[*].id contains only expectedDirectCapabilityIds

    # Verify the expanded user capabilities include direct user assignments and the user capability set expansion.
    Given path 'users', subjectUserId, 'capabilities'
    And param expand = true
    And param includeDummy = true
    And param limit = 50
    When method get
    Then status 200
    And match response.capabilities[*].id contains only expectedExpandedCapabilityIds

    # Verify the effective permission list includes direct user, user capability set, role capability, and role capability set assignments.
    Given path 'permissions', 'users', subjectUserId
    When method get
    Then status 200
    And match response.userId == subjectUserId
    And match response.permissions contains only expectedPermissions

    # Clean up the created role after the verification.
    Given path 'roles', roleId
    When method delete
    Then status 204
