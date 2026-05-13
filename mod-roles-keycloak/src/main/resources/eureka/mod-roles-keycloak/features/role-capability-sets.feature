Feature: CRUD operations on role capability sets

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: assign, list, update, and delete role capability sets
    # Create a role that will be used for capability-set linking.
    * def roleName = 'karate-role-capability-sets-' + nowMillis()
    * def createRoleRequest =
      """
      {
        "name": "#(roleName)",
        "description": "Role for role capability set Karate tests",
        "type": "REGULAR"
      }
      """

    Given path 'roles'
    And request createRoleRequest
    When method post
    Then status 201
    And match response.id == '#uuid'
    * def roleId = response.id
    * def generatedPolicyName = 'Policy for role: ' + roleId

    # Resolve known capability sets and remember child capabilities for validation.
    * def firstCapabilitySetPermission = 'role-capability-sets.all'
    * def secondCapabilitySetPermission = 'user-capabilities.all'
    * def thirdCapabilitySetPermission = 'user-capability-sets.all'
    * def firstCapabilitySet = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilitySetByPermission', { capabilitySetPermission: firstCapabilitySetPermission })
    * def secondCapabilitySet = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilitySetByPermission', { capabilitySetPermission: secondCapabilitySetPermission })
    * def thirdCapabilitySet = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilitySetByPermission', { capabilitySetPermission: thirdCapabilitySetPermission })
    * assert firstCapabilitySet.capabilityIds.length > 0
    * assert secondCapabilitySet.capabilityIds.length > 0

    # A role policy is created lazily, only when capability sets are assigned to the role.
    Given path 'policies'
    And param query = 'name=="' + generatedPolicyName + '"'
    When method get
    Then status 200
    And match response.totalRecords == 0
    And match response.policies == []

    # Link two capability sets in one request: one by ID and one by name.
    * def assignRoleCapabilitySetsRequest =
      """
      {
        "roleId": "#(roleId)",
        "capabilitySetIds": ["#(firstCapabilitySet.capabilitySet.id)"],
        "capabilitySetNames": ["#(secondCapabilitySet.capabilitySet.name)"]
      }
      """
    Given path 'roles', 'capability-sets'
    And request assignRoleCapabilitySetsRequest
    When method post
    Then status 201
    And match response.totalRecords == 2
    And match response.roleCapabilitySets[*].roleId contains roleId
    And match response.roleCapabilitySets[*].capabilitySetId contains firstCapabilitySet.capabilitySet.id
    And match response.roleCapabilitySets[*].capabilitySetId contains secondCapabilitySet.capabilitySet.id

    # Verify that assigning capability sets also creates a role policy.
    Given path 'policies'
    And param query = 'name=="' + generatedPolicyName + '"'
    When method get
    Then status 200
    And match response.totalRecords == 1
    And match response.policies == '#[1]'
    And match response.policies[0] contains deep
      """
      {
        name: '#(generatedPolicyName)',
        description: '#("System generated policy for role: " + roleId)',
        type: 'ROLE',
        source: 'SYSTEM',
        rolePolicy: {
          roles: [
            { id: '#(roleId)' }
          ]
        }
      }
      """

    # Verify that the capability sets were added to the role.
    Given path 'roles', 'capability-sets'
    And param query = 'roleId=="' + roleId + '"'
    When method get
    Then status 200
    And match response.roleCapabilitySets[*].roleId contains roleId
    And match response.roleCapabilitySets[*].capabilitySetId contains firstCapabilitySet.capabilitySet.id
    And match response.roleCapabilitySets[*].capabilitySetId contains secondCapabilitySet.capabilitySet.id

    Given path 'roles', roleId, 'capability-sets'
    When method get
    Then status 200
    And match response.totalRecords == 2
    And match response.capabilitySets contains deep { id: '#(firstCapabilitySet.capabilitySet.id)', name: '#(firstCapabilitySet.capabilitySet.name)' }
    And match response.capabilitySets contains deep { id: '#(secondCapabilitySet.capabilitySet.id)', name: '#(secondCapabilitySet.capabilitySet.name)' }

    # Confirm that child capabilities from assigned sets appear on the expanded role capabilities API.
    Given path 'roles', roleId, 'capabilities'
    And param expand = true
    When method get
    Then status 200
    And match response.capabilities[*].id contains firstCapabilitySet.capabilityIds
    And match response.capabilities[*].id contains secondCapabilitySet.capabilityIds

    # Update the linked set to keep one capability set and replace the other.
    * def updateRoleCapabilitySetsRequest =
      """
      {
        "capabilitySetIds": ["#(firstCapabilitySet.capabilitySet.id)"],
        "capabilitySetNames": ["#(thirdCapabilitySet.capabilitySet.name)"]
      }
      """
    Given path 'roles', roleId, 'capability-sets'
    And request updateRoleCapabilitySetsRequest
    When method put
    Then status 204

    Given path 'roles', roleId, 'capability-sets'
    When method get
    Then status 200
    And match response.totalRecords == 2
    And match response.capabilitySets contains deep { id: '#(firstCapabilitySet.capabilitySet.id)', name: '#(firstCapabilitySet.capabilitySet.name)' }
    And match response.capabilitySets contains deep { id: '#(thirdCapabilitySet.capabilitySet.id)', name: '#(thirdCapabilitySet.capabilitySet.name)' }

    # Remove all role capability-set links and delete the test role.
    Given path 'roles', roleId, 'capability-sets'
    When method delete
    Then status 204

    Given path 'roles', roleId, 'capability-sets'
    When method get
    Then status 200
    And match response.totalRecords == 0
    And match response.capabilitySets == []

    Given path 'roles', roleId
    When method delete
    Then status 204

    # Deleting the role should also clean up the generated policy.
    Given path 'roles', roleId
    When method get
    Then status 404
    And match response.errors == '#array'

    Given path 'policies'
    And param query = 'name=="' + generatedPolicyName + '"'
    When method get
    Then status 200
    And match response.totalRecords == 0
    And match response.policies == []

  @Negative
  Scenario: assigning role capability sets with unknown names returns 400
    * def roleId = uuid()
    * def assignRoleCapabilitySetsRequest =
      """
      {
        "roleId": "#(roleId)",
        "capabilitySetNames": ["boo_item.create"]
      }
      """
    Given path 'roles', 'capability-sets'
    And request assignRoleCapabilitySetsRequest
    When method post
    Then status 400
    And match response.errors == '#array'

  @Negative
  Scenario: updating capability sets for a non-existing role returns 404
    * def firstCapabilitySetPermission = 'role-capability-sets.all'
    * def firstCapabilitySet = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilitySetByPermission', { capabilitySetPermission: firstCapabilitySetPermission })
    * def missingRoleId = uuid()
    * def updateRoleCapabilitySetsRequest = ({ capabilitySetIds: [firstCapabilitySet.capabilitySet.id] })
    Given path 'roles', missingRoleId, 'capability-sets'
    And request updateRoleCapabilitySetsRequest
    When method put
    Then status 404
    And match response.errors == '#array'
