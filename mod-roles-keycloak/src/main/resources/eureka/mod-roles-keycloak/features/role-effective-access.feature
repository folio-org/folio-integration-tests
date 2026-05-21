Feature: Role effective access resolution

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: role capabilities reflect direct and capability set assignments with deduping
    # Access paths covered by this scenario:
    # role -> capability
    # role -> capability set -> capabilities

    # Resolve a direct capability that also exists inside the selected capability set.
    * def directCapabilityPermission = 'roles.users.item.get'
    * def roleCapabilitySetPermission = 'roles.users.all'

    * def directCapability = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilityByPermission', ({ capabilityPermission: directCapabilityPermission })).capability
    * def roleCapabilitySet = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilitySetByPermission', ({ capabilitySetPermission: roleCapabilitySetPermission }))

    # Create a role that will receive the direct capability and the capability set.
    * def roleName = 'karate-role-effective-access-' + nowMillis()
    * def roleId = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/role-helpers.feature@createRole', ({ roleName: roleName, roleDescription: 'Role for effective role access Karate tests', roleType: 'REGULAR' })).roleId

    # Assign the direct capability to the role.
    * def assignRoleCapabilitiesRequest = ({ roleId: roleId, capabilityIds: [directCapability.id] })
    Given path 'roles', 'capabilities'
    And request assignRoleCapabilitiesRequest
    When method post
    Then status 201
    And match response.roleCapabilities[*].capabilityId contains directCapability.id

    # Assign the capability set that already contains the same capability.
    * def assignRoleCapabilitySetsRequest = ({ roleId: roleId, capabilitySetIds: [roleCapabilitySet.capabilitySet.id] })
    Given path 'roles', 'capability-sets'
    And request assignRoleCapabilitySetsRequest
    When method post
    Then status 201
    And match response.roleCapabilitySets[*].capabilitySetId contains roleCapabilitySet.capabilitySet.id

    # Build the expected direct and expanded capability ids, with the expanded list deduped.
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
    * def expectedDirectCapabilityIds = ([directCapability.id])
    * def expectedExpandedCapabilityIds = distinct(([directCapability.id]).concat(roleCapabilitySet.capabilityIds))

    # Verify expand=false returns only directly assigned role capabilities.
    Given path 'roles', roleId, 'capabilities'
    And param expand = false
    And param includeDummy = false
    And param limit = 50
    When method get
    Then status 200
    And match response.capabilities[*].id contains only expectedDirectCapabilityIds

    # Verify expand=true returns the union of direct capabilities and capability set children without duplicates.
    Given path 'roles', roleId, 'capabilities'
    And param expand = true
    And param includeDummy = false
    And param limit = 50
    When method get
    Then status 200
    And match response.capabilities[*].id contains only expectedExpandedCapabilityIds

    # Clean up the created role after the verification.
    Given path 'roles', roleId
    When method delete
    Then status 204
