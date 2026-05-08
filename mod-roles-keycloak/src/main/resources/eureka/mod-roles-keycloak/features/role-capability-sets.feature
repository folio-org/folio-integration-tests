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

    # Discover several capability sets and remember child capabilities for validation.
    Given path 'capability-sets'
    And param limit = 3
    When method get
    Then status 200
    And match response.capabilitySets == '#array'
    And assert response.capabilitySets.length >= 3
    * def firstCapabilitySetId = response.capabilitySets[0].id
    * def firstCapabilitySetName = response.capabilitySets[0].name
    * assert response.capabilitySets[0].capabilities.length > 0
    * def firstDerivedCapabilityId = response.capabilitySets[0].capabilities[0]
    * def secondCapabilitySetId = response.capabilitySets[1].id
    * def secondCapabilitySetName = response.capabilitySets[1].name
    * assert response.capabilitySets[1].capabilities.length > 0
    * def secondDerivedCapabilityId = response.capabilitySets[1].capabilities[0]
    * def thirdCapabilitySetId = response.capabilitySets[2].id
    * def thirdCapabilitySetName = response.capabilitySets[2].name

    # Link two capability sets in one request: one by ID and one by name.
    * def assignRoleCapabilitySetsRequest =
      """
      {
        "roleId": "#(roleId)",
        "capabilitySetIds": ["#(firstCapabilitySetId)"],
        "capabilitySetNames": ["#(secondCapabilitySetName)"]
      }
      """
    Given path 'roles', 'capability-sets'
    And request assignRoleCapabilitySetsRequest
    When method post
    Then status 201
    And match response.totalRecords == 2
    And match response.roleCapabilitySets[*].roleId contains roleId
    And match response.roleCapabilitySets[*].capabilitySetId contains firstCapabilitySetId
    And match response.roleCapabilitySets[*].capabilitySetId contains secondCapabilitySetId

    # Verify that the capability sets were added to the role.
    Given path 'roles', 'capability-sets'
    And param query = 'roleId=="' + roleId + '"'
    When method get
    Then status 200
    And match response.roleCapabilitySets[*].roleId contains roleId
    And match response.roleCapabilitySets[*].capabilitySetId contains firstCapabilitySetId
    And match response.roleCapabilitySets[*].capabilitySetId contains secondCapabilitySetId

    Given path 'roles', roleId, 'capability-sets'
    When method get
    Then status 200
    And match response.totalRecords == 2
    And match response.capabilitySets[*].id contains firstCapabilitySetId
    And match response.capabilitySets[*].id contains secondCapabilitySetId
    And match response.capabilitySets[*].name contains firstCapabilitySetName
    And match response.capabilitySets[*].name contains secondCapabilitySetName

    # Confirm that child capabilities from assigned sets appear on the expanded role capabilities API.
    Given path 'roles', roleId, 'capabilities'
    And param expand = true
    When method get
    Then status 200
    And match response.capabilities[*].id contains firstDerivedCapabilityId
    And match response.capabilities[*].id contains secondDerivedCapabilityId

    # Update the linked set to keep one capability set and replace the other.
    * def updateRoleCapabilitySetsRequest =
      """
      {
        "capabilitySetIds": ["#(firstCapabilitySetId)"],
        "capabilitySetNames": ["#(thirdCapabilitySetName)"]
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
    And match response.capabilitySets[*].id contains firstCapabilitySetId
    And match response.capabilitySets[*].id contains thirdCapabilitySetId
    And match response.capabilitySets[*].name contains firstCapabilitySetName
    And match response.capabilitySets[*].name contains thirdCapabilitySetName

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
