Feature: CRUD operations on user capabilities

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: assign, list, update, and delete user capabilities
    # Resolve several known capabilities
    * def baselineCapabilityPermission = 'role-capabilities.collection.delete'
    * def firstCapabilityPermission = 'role-capabilities.collection.post'
    * def secondCapabilityPermission = 'role-capabilities.collection.put'
    * def thirdCapabilityPermission = 'roles.collection.get'

    * def baselineCapability = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilityByPermission', { capabilityPermission: baselineCapabilityPermission }).capability
    * def firstCapability = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilityByPermission', { capabilityPermission: firstCapabilityPermission }).capability
    * def secondCapability = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilityByPermission', { capabilityPermission: secondCapabilityPermission }).capability
    * def thirdCapability = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilityByPermission', { capabilityPermission: thirdCapabilityPermission }).capability

    # Create a user, with a baseline permission
    * def subjectUserName = 'user-capabilities-user-' + nowMillis()
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

    # Assigning direct capabilities to the user creates a USER policy.
    * def generatedPolicyName = 'Policy for user: ' + subjectUserId
    Given path 'policies'
    And param query = 'name=="' + generatedPolicyName + '"'
    When method get
    Then status 200
    And match response.policies == '#[1]'
    And match response.policies[0] contains deep
      """
      {
        name: '#(generatedPolicyName)',
        description: '#("System generated policy for user: " + subjectUserId)',
        type: 'USER',
        source: 'SYSTEM',
        userPolicy: {
          users: ['#(subjectUserId)']
        }
      }
      """

    # Assign two capabilities to the user.
    * def assignUserCapabilitiesRequest = ({ userId: subjectUserId, capabilityIds: [firstCapability.id, secondCapability.id] })
    Given path 'users', 'capabilities'
    And request assignUserCapabilitiesRequest
    When method post
    Then status 201
    And match response.totalRecords == 2
    And match response.userCapabilities[*].userId contains subjectUserId
    And match response.userCapabilities[*].capabilityId contains firstCapability.id
    And match response.userCapabilities[*].capabilityId contains secondCapability.id

    # verify that the user-capability relations were created.
    Given path 'users', 'capabilities'
    And param query = 'userId=="' + subjectUserId + '"'
    When method get
    Then status 200
    And match response.totalRecords == 3
    And match response.userCapabilities[*].userId contains subjectUserId
    And match response.userCapabilities[*].capabilityId contains baselineCapability.id
    And match response.userCapabilities[*].capabilityId contains firstCapability.id
    And match response.userCapabilities[*].capabilityId contains secondCapability.id

    Given path 'users', subjectUserId, 'capabilities'
    When method get
    Then status 200
    And match response.totalRecords == 3
    And match response.capabilities contains deep { id: '#(baselineCapability.id)', name: '#(baselineCapability.name)', permission: '#(baselineCapability.permission)' }
    And match response.capabilities contains deep { id: '#(firstCapability.id)', name: '#(firstCapability.name)', permission: '#(firstCapability.permission)' }
    And match response.capabilities contains deep { id: '#(secondCapability.id)', name: '#(secondCapability.name)', permission: '#(secondCapability.permission)' }

    # Verify effective user permissions reflect the direct capability assignments.
    Given path 'permissions', 'users', subjectUserId
    When method get
    Then status 200
    And match response.userId == subjectUserId
    And match response.permissions contains only ['#(baselineCapabilityPermission)', '#(firstCapabilityPermission)', '#(secondCapabilityPermission)']

    # Update user capabilities
    * def updateUserCapabilitiesRequest = ({ capabilityIds: [firstCapability.id, thirdCapability.id] })
    Given path 'users', subjectUserId, 'capabilities'
    And request updateUserCapabilitiesRequest
    When method put
    Then status 204

    # Verify that the user-capability relations are updated.
    Given path 'users', subjectUserId, 'capabilities'
    When method get
    Then status 200
    And match response.totalRecords == 2
    And match response.capabilities contains deep { id: '#(firstCapability.id)', name: '#(firstCapability.name)', permission: '#(firstCapability.permission)' }
    And match response.capabilities contains deep { id: '#(thirdCapability.id)', name: '#(thirdCapability.name)', permission: '#(thirdCapability.permission)' }
    And assert response.capabilities.map(capability => capability.id).indexOf(baselineCapability.id) == -1
    And assert response.capabilities.map(capability => capability.id).indexOf(secondCapability.id) == -1

    # Verify effective user permissions reflect the updated capability assignments.
    Given path 'permissions', 'users', subjectUserId
    When method get
    Then status 200
    And match response.userId == subjectUserId
    And match response.permissions contains only ['#(firstCapabilityPermission)', '#(thirdCapabilityPermission)']

    # Remove all user-capability links.
    Given path 'users', subjectUserId, 'capabilities'
    When method delete
    Then status 204

    Given path 'users', subjectUserId, 'capabilities'
    When method get
    Then status 200
    And match response.totalRecords == 0
    And match response.capabilities == []

    # Deleting capabilities removes permissions.
    Given path 'permissions', 'users', subjectUserId
    When method get
    Then status 200
    And match response.userId == subjectUserId
    And match response.permissions == []

  @Positive
  Scenario: deleting a user removes user capabilities and policies
    # Create a user with one direct capability assigned during provisioning
    * def capabilityPermission = 'role-capabilities.collection.delete'
    * def capability = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilityByPermission', { capabilityPermission: capabilityPermission }).capability

    * def subjectUserName = 'user-capabilities-delete-user-' + nowMillis()
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
        { "name": "#(capabilityPermission)" }
      ]
      """
    * configure headers = null
    * def createUserResult = call read('classpath:common/eureka/create-additional-user.feature') { testUser: #(subjectUser), userPermissions: #(subjectUserPermissions) }
    * def subjectUserId = createUserResult.userId
    * def testUserHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = testUserHeaders

    # Verify capability and plicy exists for the user
    Given path 'users', 'capabilities'
    And param query = 'userId=="' + subjectUserId + '"'
    When method get
    Then status 200
    And match response.totalRecords == 1
    And match response.userCapabilities[*].capabilityId contains capability.id

    * def generatedPolicyName = 'Policy for user: ' + subjectUserId
    Given path 'policies'
    And param query = 'name=="' + generatedPolicyName + '"'
    When method get
    Then status 200
    And match response.policies == '#[1]'

    # Delete the user through mod-users-keycloak.
    * call login testAdmin
    * def testAdminHeaders = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }
    * configure headers = testAdminHeaders
    Given path 'users-keycloak', 'users', subjectUserId
    When method delete
    Then status 204

    # Verify that capability and policy is removed.
    * configure headers = testUserHeaders
    * configure retry = { count: 10, interval: 1000 }
    Given path 'users', 'capabilities'
    And param query = 'userId=="' + subjectUserId + '"'
    And retry until responseStatus == 200 && response.totalRecords == 0
    When method get
    Then status 200
    And match response.userCapabilities == []

    Given path 'policies'
    And param query = 'name=="' + generatedPolicyName + '"'
    And retry until responseStatus == 200 && response.totalRecords == 0
    When method get
    Then status 200
    And match response.policies == []

  @Negative
  Scenario: updating capabilities for a non-existing user returns 404
    * def firstCapabilityPermission = 'role-capabilities.collection.post'
    * def firstCapability = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilityByPermission', { capabilityPermission: firstCapabilityPermission }).capability
    * def missingUserId = uuid()
    * def updateUserCapabilitiesRequest = ({ capabilityIds: [firstCapability.id] })
    Given path 'users', missingUserId, 'capabilities'
    And request updateUserCapabilitiesRequest
    When method put
    Then status 404
    And match response.errors == '#array'
