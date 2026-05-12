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

    # Discover several capabilities so the test can mix IDs and names.
    Given path 'capabilities'
    And param limit = 3
    When method get
    Then status 200
    And match response.capabilities == '#array'
    And assert response.capabilities.length >= 3
    * def firstCapabilityId = response.capabilities[0].id
    * def firstCapabilityName = response.capabilities[0].name
    * def secondCapabilityId = response.capabilities[1].id
    * def secondCapabilityName = response.capabilities[1].name
    * def thirdCapabilityId = response.capabilities[2].id
    * def thirdCapabilityName = response.capabilities[2].name

    # Link two capabilities in one request: one by ID and one by name.
    * def assignRoleCapabilitiesRequest =
      """
      {
        "roleId": "#(roleId)",
        "capabilityIds": ["#(firstCapabilityId)"],
        "capabilityNames": ["#(secondCapabilityName)"]
      }
      """
    Given path 'roles', 'capabilities'
    And request assignRoleCapabilitiesRequest
    When method post
    Then status 201
    And match response.totalRecords == 2
    And match response.roleCapabilities[*].roleId contains roleId
    And match response.roleCapabilities[*].capabilityId contains firstCapabilityId
    And match response.roleCapabilities[*].capabilityId contains secondCapabilityId

    # Verify that the capabilities were added to the role.
    Given path 'roles', 'capabilities'
    And param query = 'roleId=="' + roleId + '"'
    When method get
    Then status 200
    And match response.roleCapabilities[*].roleId contains roleId
    And match response.roleCapabilities[*].capabilityId contains firstCapabilityId
    And match response.roleCapabilities[*].capabilityId contains secondCapabilityId

    Given path 'roles', roleId, 'capabilities'
    When method get
    Then status 200
    And match response.totalRecords == 2
    And match response.capabilities[*].id contains firstCapabilityId
    And match response.capabilities[*].id contains secondCapabilityId
    And match response.capabilities[*].name contains firstCapabilityName
    And match response.capabilities[*].name contains secondCapabilityName

    # Update the linked set to keep one capability and replace the other.
    * def updateRoleCapabilitiesRequest =
      """
      {
        "capabilityIds": ["#(firstCapabilityId)"],
        "capabilityNames": ["#(thirdCapabilityName)"]
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
    And match response.capabilities[*].id contains firstCapabilityId
    And match response.capabilities[*].id contains thirdCapabilityId
    And match response.capabilities[*].name contains firstCapabilityName
    And match response.capabilities[*].name contains thirdCapabilityName

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
