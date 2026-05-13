Feature: CRUD operations on role capabilities

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: assign, list, update, and delete role capabilities
    # Create a role that will be used for capability linking.
    * def roleName = 'karate-role-capabilities-' + nowMillis()
    * def createRoleRequest =
      """
      {
        "name": "#(roleName)",
        "description": "Role for role capability Karate tests",
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

    # Resolve known capabilities so the test can mix IDs and names and assert policy creation.
    * def firstCapabilityPermission = 'role-capabilities.collection.post'
    * def secondCapabilityPermission = 'role-capabilities.collection.get'
    * def thirdCapabilityPermission = 'role-capabilities.collection.put'
    * def firstCapability = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilityByPermission', { capabilityPermission: firstCapabilityPermission }).capability
    * def secondCapability = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilityByPermission', { capabilityPermission: secondCapabilityPermission }).capability
    * def thirdCapability = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilityByPermission', { capabilityPermission: thirdCapabilityPermission }).capability

    # A role policy is created lazily, only when capabilities are assigned to the role.
    Given path 'policies'
    And param query = 'name=="' + generatedPolicyName + '"'
    When method get
    Then status 200
    And match response.totalRecords == 0
    And match response.policies == []

    # Link two capabilities in one request: one by ID and one by name.
    * def assignRoleCapabilitiesRequest =
      """
      {
        "roleId": "#(roleId)",
        "capabilityIds": ["#(firstCapability.id)"],
        "capabilityNames": ["#(secondCapability.name)"]
      }
      """
    Given path 'roles', 'capabilities'
    And request assignRoleCapabilitiesRequest
    When method post
    Then status 201
    And match response.totalRecords == 2
    And match response.roleCapabilities[*].roleId contains roleId
    And match response.roleCapabilities[*].capabilityId contains firstCapability.id
    And match response.roleCapabilities[*].capabilityId contains secondCapability.id

    # Verify that assigning capabilities also creates a role policy.
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

    # Verify that the capabilities were added to the role.
    Given path 'roles', 'capabilities'
    And param query = 'roleId=="' + roleId + '"'
    When method get
    Then status 200
    And match response.roleCapabilities[*].roleId contains roleId
    And match response.roleCapabilities[*].capabilityId contains firstCapability.id
    And match response.roleCapabilities[*].capabilityId contains secondCapability.id

    Given path 'roles', roleId, 'capabilities'
    When method get
    Then status 200
    And match response.totalRecords == 2
    And match response.capabilities contains deep { id: '#(firstCapability.id)', name: '#(firstCapability.name)' }
    And match response.capabilities contains deep { id: '#(secondCapability.id)', name: '#(secondCapability.name)' }

    # Update the linked set to keep one capability and replace the other.
    * def updateRoleCapabilitiesRequest =
      """
      {
        "capabilityIds": ["#(firstCapability.id)"],
        "capabilityNames": ["#(thirdCapability.name)"]
      }
      """
    Given path 'roles', roleId, 'capabilities'
    And request updateRoleCapabilitiesRequest
    When method put
    Then status 204

    Given path 'roles', roleId, 'capabilities'
    When method get
    Then status 200
    And match response.totalRecords == 2
    And match response.capabilities contains deep { id: '#(firstCapability.id)', name: '#(firstCapability.name)' }
    And match response.capabilities contains deep { id: '#(thirdCapability.id)', name: '#(thirdCapability.name)' }

    # Remove all role-capability links and delete the test role.
    Given path 'roles', roleId, 'capabilities'
    When method delete
    Then status 204

    Given path 'roles', roleId, 'capabilities'
    When method get
    Then status 200
    And match response.totalRecords == 0
    And match response.capabilities == []

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
  Scenario: assigning role capabilities with unknown names returns 400
    * def roleId = uuid()
    * def assignRoleCapabilitiesRequest =
      """
      {
        "roleId": "#(roleId)",
        "capabilityNames": ["boo_item.create"]
      }
      """
    Given path 'roles', 'capabilities'
    And request assignRoleCapabilitiesRequest
    When method post
    Then status 400
    And match response.errors == '#array'

  @Negative
  Scenario: updating capabilities for a non-existing role returns 404
    * def firstCapabilityPermission = 'role-capabilities.collection.post'
    * def firstCapability = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilityByPermission', { capabilityPermission: firstCapabilityPermission }).capability
    * def missingRoleId = uuid()
    * def updateRoleCapabilitiesRequest = ({ capabilityIds: [firstCapability.id] })
    Given path 'roles', missingRoleId, 'capabilities'
    And request updateRoleCapabilitiesRequest
    When method put
    Then status 404
    And match response.errors == '#array'
