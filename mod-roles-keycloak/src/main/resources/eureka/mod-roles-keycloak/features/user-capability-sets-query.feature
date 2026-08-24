Feature: Batch query of effective user capability sets

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: query effective capability sets combining direct and role-inherited assignments
    # Resolve known capability sets: assigned both directly and through a role, and only through a role.
    * def directCapabilitySetPermission = 'role-capability-sets.all'
    * def inheritedCapabilitySetPermission = 'user-capability-sets.all'
    * def directCapabilitySet = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilitySetByPermission', ({ capabilitySetPermission: directCapabilitySetPermission }))
    * def inheritedCapabilitySet = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/lookup-helpers.feature@getCapabilitySetByPermission', ({ capabilitySetPermission: inheritedCapabilitySetPermission }))

    # Create a role and link both capability sets to it.
    * def roleName = 'karate-user-capability-sets-query-' + nowMillis()
    * def roleId = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/role-helpers.feature@createRole', ({ roleName: roleName, roleDescription: 'Role for user capability-sets query Karate tests', roleType: 'REGULAR' })).roleId
    * def assignRoleCapabilitySetsRequest =
      """
      {
        "roleId": "#(roleId)",
        "capabilitySetIds": ["#(directCapabilitySet.capabilitySet.id)", "#(inheritedCapabilitySet.capabilitySet.id)"]
      }
      """
    Given path 'roles', 'capability-sets'
    And request assignRoleCapabilitySetsRequest
    When method post
    Then status 201
    And match response.totalRecords == 2

    # Create a user with assignments and a user without any capability-set assignments.
    * def baselineUserPermission = 'roles.collection.get'
    * def subjectUserName = 'user-capability-sets-query-user-' + nowMillis()
    * def emptyUserName = 'user-capability-sets-query-empty-user-' + nowMillis()
    * def subjectUserPermissions = ([{ name: baselineUserPermission }])
    * def subjectUserId = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/user-helpers.feature@createAdditionalUser', ({ userName: subjectUserName, userPermissions: subjectUserPermissions })).userId
    * def emptyUserId = karate.call('classpath:eureka/mod-roles-keycloak/features/helpers/user-helpers.feature@createAdditionalUser', ({ userName: emptyUserName, userPermissions: subjectUserPermissions })).userId

    # Assign one capability set directly to the subject user and the role to the same user,
    # so the directly assigned set is also inherited through the role and must be returned once.
    * def assignUserCapabilitySetsRequest =
      """
      {
        "userId": "#(subjectUserId)",
        "capabilitySetIds": ["#(directCapabilitySet.capabilitySet.id)"]
      }
      """
    Given path 'users', 'capability-sets'
    And request assignUserCapabilitySetsRequest
    When method post
    Then status 201
    And match response.totalRecords == 1

    * def assignUserRolesRequest =
      """
      {
        "userId": "#(subjectUserId)",
        "roleIds": ["#(roleId)"]
      }
      """
    Given path 'roles', 'users'
    And request assignUserRolesRequest
    When method post
    Then status 201

    # Query without a whitelist: the subject user gets the deduplicated union of direct and
    # role-inherited names, and every requested user is represented exactly once, in request order.
    * def unknownUserId = uuid()
    * def expectedSubjectNames = karate.sort([directCapabilitySet.capabilitySet.name, inheritedCapabilitySet.capabilitySet.name])
    * def queryWithoutWhitelistRequest =
      """
      {
        "userIds": ["#(subjectUserId)", "#(emptyUserId)", "#(unknownUserId)"]
      }
      """
    Given path 'users', 'capability-sets', 'query'
    And request queryWithoutWhitelistRequest
    When method post
    Then status 200
    And match response.userCapabilitySets ==
      """
      [
        { userId: '#(subjectUserId)', capabilitySetNames: '#(expectedSubjectNames)' },
        { userId: '#(emptyUserId)', capabilitySetNames: [] },
        { userId: '#(unknownUserId)', capabilitySetNames: [] }
      ]
      """

    # Query with a whitelist containing one known and one unknown name: only exact matches
    # are returned and the unknown name contributes no result and no request failure.
    * def unknownCapabilitySetName = 'nonexistent-capability-set-' + uuid()
    * def queryWithWhitelistRequest =
      """
      {
        "userIds": ["#(subjectUserId)", "#(emptyUserId)"],
        "capabilitySetNames": ["#(directCapabilitySet.capabilitySet.name)", "#(unknownCapabilitySetName)"]
      }
      """
    Given path 'users', 'capability-sets', 'query'
    And request queryWithWhitelistRequest
    When method post
    Then status 200
    And match response.userCapabilitySets ==
      """
      [
        { userId: '#(subjectUserId)', capabilitySetNames: ['#(directCapabilitySet.capabilitySet.name)'] },
        { userId: '#(emptyUserId)', capabilitySetNames: [] }
      ]
      """

    # Remove user capability-set links, user-role links, role capability-set links and the role.
    Given path 'users', subjectUserId, 'capability-sets'
    When method delete
    Then status 204

    Given path 'roles', 'users', subjectUserId
    When method delete
    Then status 204

    Given path 'roles', roleId, 'capability-sets'
    When method delete
    Then status 204

    Given path 'roles', roleId
    When method delete
    Then status 204

  @Negative
  Scenario: querying capability sets with invalid userIds returns 400
    # More than 500 user IDs is a schema violation rejected with a validation error on 'userIds'.
    * def tooManyUserIds = karate.repeat(501, i => uuid())
    * def oversizedRequest = ({ userIds: tooManyUserIds })
    Given path 'users', 'capability-sets', 'query'
    And request oversizedRequest
    When method post
    Then status 400
    And match response.errors[0].code == 'validation_error'
    And match response.errors[0].parameters[0].key == 'userIds'

    # An empty userIds array is also rejected.
    * def emptyRequest = ({ userIds: [] })
    Given path 'users', 'capability-sets', 'query'
    And request emptyRequest
    When method post
    Then status 400
    And match response.errors == '#array'
