Feature: User permissions reflect role capability-set changes

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: user permissions reflect updated role capability sets
    # Create a role.
    * def roleName = 'karate-role-capability-set-user-permissions-' + nowMillis()
    * def createRoleRequest =
      """
      {
        "name": "#(roleName)",
        "description": "Role for user permission refresh through capability sets Karate tests",
        "type": "REGULAR"
      }
      """

    Given path 'roles'
    And request createRoleRequest
    When method post
    Then status 201
    And match response.id == '#uuid'
    * def roleId = response.id

    # Resolve the capability sets corresponding to the predefined permission names.
    * def firstCapabilitySetPermission = 'role-capabilities.all'
    * def secondCapabilitySetPermission = 'role-capability-sets.all'
    * def baselineCapabilityPermission = 'role-capabilities.collection.post'

    Given path 'capabilities'
    And param query = 'permission=="' + baselineCapabilityPermission + '"'
    When method get
    Then status 200
    And match response.capabilities == '#[1]'

    Given path 'capability-sets'
    And param query = 'permission=="' + firstCapabilitySetPermission + '"'
    When method get
    Then status 200
    And match response.capabilitySets == '#[1]'
    * def firstCapabilitySet = response.capabilitySets[0]

    Given path 'capability-sets'
    And param query = 'permission=="' + secondCapabilitySetPermission + '"'
    When method get
    Then status 200
    And match response.capabilitySets == '#[1]'
    * def secondCapabilitySet = response.capabilitySets[0]

    Given path 'capability-sets', firstCapabilitySet.id, 'capabilities'
    When method get
    Then status 200
    And match response.capabilities == '#array'
    * def firstCapabilitySetPermissions = response.capabilities.map(capability => capability.permission)

    Given path 'capability-sets', secondCapabilitySet.id, 'capabilities'
    When method get
    Then status 200
    And match response.capabilities == '#array'
    * def secondCapabilitySetPermissions = response.capabilities.map(capability => capability.permission)
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
        { "name": "#(baselineCapabilityPermission)" }
      ]
      """
    * configure headers = null
    * def createUserResult = call read('classpath:common/eureka/create-additional-user.feature') { testUser: #(subjectUser), userPermissions: #(subjectUserPermissions) }
    * def subjectUserId = createUserResult.userId
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

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
    And assert response.permissions.length >= firstCapabilitySetPermissions.length + 1
    And match response.permissions contains baselineCapabilityPermission
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
    And assert response.permissions.length >= secondCapabilitySetPermissions.length + 1
    And match response.permissions contains baselineCapabilityPermission
    And match response.permissions contains secondCapabilitySetPermissions
    And match response.permissions !contains firstOnlyPermissions

    # Clean up the role after the verification.
    Given path 'roles', roleId
    When method delete
    Then status 204
