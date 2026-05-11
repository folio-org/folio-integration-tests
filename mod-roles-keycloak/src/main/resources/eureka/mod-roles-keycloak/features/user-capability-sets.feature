Feature: CRUD operations on user capability sets

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: assign, list, update, and delete user capability sets
    # Resolve several known capability sets and a capability
    * def firstCapabilitySetPermission = 'role-capability-sets.all'
    * def secondCapabilitySetPermission = 'user-capabilities.all'
    * def thirdCapabilitySetPermission = 'user-capability-sets.all'
    * def baselineCapabilityPermission = 'role-capabilities.collection.post'

    Given path 'capabilities'
    And param query = 'permission=="' + baselineCapabilityPermission + '"'
    When method get
    Then status 200
    And match response.capabilities == '#[1]'
    * def baselineCapability = response.capabilities[0]

    * def firstCapabilitySet = karate.call('@getCapabilitySetByPermission', { capabilitySetPermission: firstCapabilitySetPermission })
    * def secondCapabilitySet = karate.call('@getCapabilitySetByPermission', { capabilitySetPermission: secondCapabilitySetPermission })
    * def thirdCapabilitySet = karate.call('@getCapabilitySetByPermission', { capabilitySetPermission: thirdCapabilitySetPermission })

    * def firstAndThirdPermissions = firstCapabilitySet.permissions.concat(thirdCapabilitySet.permissions)
    * def secondOnlyPermissions = karate.filter(secondCapabilitySet.permissions, x => firstAndThirdPermissions.indexOf(x) == -1)
    * assert secondOnlyPermissions.length > 0

    * def firstAndThirdCapabilityIds = firstCapabilitySet.capabilityIds.concat(thirdCapabilitySet.capabilityIds)
    * def secondOnlyCapabilityIds = karate.filter(secondCapabilitySet.capabilityIds, x => firstAndThirdCapabilityIds.indexOf(x) == -1)
    * assert secondOnlyCapabilityIds.length > 0

    # Create a user with one baseline permission.
    * def subjectUserName = 'user-capability-sets-user-' + nowMillis()
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

    # Assign two capability sets to the user.
    * def assignUserCapabilitySetsRequest = ({ userId: subjectUserId, capabilitySetIds: [firstCapabilitySet.capabilitySet.id, secondCapabilitySet.capabilitySet.id] })
    Given path 'users', 'capability-sets'
    And request assignUserCapabilitySetsRequest
    When method post
    Then status 201
    And match response.totalRecords == 2
    And match response.userCapabilitySets[*].userId contains subjectUserId
    And match response.userCapabilitySets[*].capabilitySetId contains firstCapabilitySet.capabilitySet.id
    And match response.userCapabilitySets[*].capabilitySetId contains secondCapabilitySet.capabilitySet.id

    # Verify that the user-capability-set relations were created.
    Given path 'users', 'capability-sets'
    And param query = 'userId=="' + subjectUserId + '"'
    When method get
    Then status 200
    And match response.totalRecords == 2
    And match response.userCapabilitySets[*].userId contains subjectUserId
    And match response.userCapabilitySets[*].capabilitySetId contains firstCapabilitySet.capabilitySet.id
    And match response.userCapabilitySets[*].capabilitySetId contains secondCapabilitySet.capabilitySet.id

    Given path 'users', subjectUserId, 'capability-sets'
    When method get
    Then status 200
    And match response.totalRecords == 2
    And match response.capabilitySets contains deep { id: '#(firstCapabilitySet.capabilitySet.id)', name: '#(firstCapabilitySet.capabilitySet.name)', permission: '#(firstCapabilitySet.capabilitySet.permission)' }
    And match response.capabilitySets contains deep { id: '#(secondCapabilitySet.capabilitySet.id)', name: '#(secondCapabilitySet.capabilitySet.name)', permission: '#(secondCapabilitySet.capabilitySet.permission)' }

    # Fetch the user's effective capabilities and verify the children of the assigned capability sets are present.
    Given path 'users', subjectUserId, 'capabilities'
    And param expand = true
    And param includeDummy = true
    And param limit = 20
    When method get
    Then status 200
    And match response.capabilities[*].id contains baselineCapability.id
    And match response.capabilities[*].id contains firstCapabilitySet.capabilityIds
    And match response.capabilities[*].id contains secondCapabilitySet.capabilityIds

    # Verify effective user permissions reflect the assigned capability sets and the direct baseline permission.
    Given path 'permissions', 'users', subjectUserId
    When method get
    Then status 200
    And match response.userId == subjectUserId
    And match response.permissions contains baselineCapabilityPermission
    And match response.permissions contains firstCapabilitySet.permissions
    And match response.permissions contains secondCapabilitySet.permissions

    # Update the assigned set and replace the baseline and second capability sets.
    * def updateUserCapabilitySetsRequest = ({ capabilitySetIds: [firstCapabilitySet.capabilitySet.id, thirdCapabilitySet.capabilitySet.id] })
    Given path 'users', subjectUserId, 'capability-sets'
    And request updateUserCapabilitySetsRequest
    When method put
    Then status 204

    Given path 'users', subjectUserId, 'capability-sets'
    When method get
    Then status 200
    And match response.totalRecords == 2
    And match response.capabilitySets contains deep { id: '#(firstCapabilitySet.capabilitySet.id)', name: '#(firstCapabilitySet.capabilitySet.name)', permission: '#(firstCapabilitySet.capabilitySet.permission)' }
    And match response.capabilitySets contains deep { id: '#(thirdCapabilitySet.capabilitySet.id)', name: '#(thirdCapabilitySet.capabilitySet.name)', permission: '#(thirdCapabilitySet.capabilitySet.permission)' }
    And assert response.capabilitySets.map(capabilitySet => capabilitySet.id).indexOf(secondCapabilitySet.capabilitySet.id) == -1

    # Fetch the user's effective capabilities and verify the children of the assigned capability sets are present.
    Given path 'users', subjectUserId, 'capabilities'
    And param expand = true
    And param includeDummy = true
    And param limit = 20
    When method get
    Then status 200
    And match response.capabilities[*].id contains baselineCapability.id
    And match response.capabilities[*].id contains firstCapabilitySet.capabilityIds
    And match response.capabilities[*].id contains thirdCapabilitySet.capabilityIds
    And match response.capabilities[*].id !contains secondOnlyCapabilityIds

    # Verify effective user permissions reflect the assigned capability sets and the direct baseline permission.
    Given path 'permissions', 'users', subjectUserId
    When method get
    Then status 200
    And match response.userId == subjectUserId
    And match response.permissions contains baselineCapabilityPermission
    And match response.permissions contains firstCapabilitySet.permissions
    And match response.permissions contains thirdCapabilitySet.permissions
    And match response.permissions !contains secondOnlyPermissions

    # Remove all user capability-set links.
    Given path 'users', subjectUserId, 'capability-sets'
    When method delete
    Then status 204

    Given path 'users', subjectUserId, 'capability-sets'
    When method get
    Then status 200
    And match response.totalRecords == 0
    And match response.capabilitySets == []

    Given path 'users', subjectUserId, 'capabilities'
    And param expand = true
    And param includeDummy = true
    And param limit = 20
    When method get
    Then status 200
    And match response.capabilities == '#[1]'
    And match response.capabilities[0] contains deep { id: '#(baselineCapability.id)', name: '#(baselineCapability.name)', permission: '#(baselineCapability.permission)' }

    Given path 'permissions', 'users', subjectUserId
    When method get
    Then status 200
    And match response.userId == subjectUserId
    And match response.permissions == ['#(baselineCapabilityPermission)']

  @ignore @getCapabilitySetByPermission
  Scenario: getCapabilitySetByPermission
    Given path 'capability-sets'
    And param query = 'permission=="' + capabilitySetPermission + '"'
    When method get
    Then status 200
    And match response.capabilitySets == '#[1]'
    * def capabilitySet = response.capabilitySets[0]
    Given path 'capability-sets', capabilitySet.id, 'capabilities'
    When method get
    Then status 200
    And match response.capabilities == '#array'
    * def capabilities = response.capabilities
    * def permissions = capabilities.map(capability => capability.permission)
    * def capabilityIds = capabilities.map(capability => capability.id)
