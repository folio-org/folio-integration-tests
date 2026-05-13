Feature: Read operations on capability sets

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: get capability sets collection
    # Read the capability sets collection and verify the response shape.
    Given path 'capability-sets'
    When method get
    Then status 200
    And match response.capabilitySets == '#array'
    And match response.totalRecords == '#number'

  @Positive
  Scenario: get capability sets collection with limit
    # Read a limited capability sets collection and verify the number of returned records.
    * def limit = 2
    Given path 'capability-sets'
    And param limit = limit
    When method get
    Then status 200
    And match response.capabilitySets == '#[2]'
    And assert response.capabilitySets.length == limit

  @Positive
  Scenario: get a capability set by id and read its capabilities
    # Resolve a known capability set by permission name and capture its identifier.
    * def capabilitySetPermission = 'role-capabilities.all'
    Given path 'capability-sets'
    And param query = 'permission=="' + capabilitySetPermission + '"'
    When method get
    Then status 200
    And match response.capabilitySets == '#[1]'
    * def capabilitySet = response.capabilitySets[0]
    * def capabilitySetId = capabilitySet.id
    * def capabilitySetName = capabilitySet.name
    * def capabilityIds = capabilitySet.capabilities
    * assert capabilityIds.length > 0

    # Read the capability set directly by ID and verify the values.
    Given path 'capability-sets', capabilitySetId
    When method get
    Then status 200
    And match response.id == capabilitySetId
    And match response.name == capabilitySetName
    And match response.permission == capabilitySetPermission
    And match response.capabilities contains capabilityIds

    # Read the child capabilities for the capability set and verify.
    Given path 'capability-sets', capabilitySetId, 'capabilities'
    And param includeDummy = true
    And param limit = capabilityIds.length
    When method get
    Then status 200
    And match response.capabilities == '#array'
    And assert response.capabilities.length == capabilityIds.length
    And assert response.totalRecords == capabilityIds.length
    And match response.capabilities[*].id contains capabilityIds
    * def childCapabilities = response.capabilities

    # Verify each child capability matches the direct capability-by-id response.
    * karate.forEach(childCapabilities, childCapability => karate.call('classpath:eureka/mod-roles-keycloak/features/capability-sets.feature@verifyChildCapabilityById', { childCapability: childCapability }))

  @ignore @verifyChildCapabilityById
  Scenario: verifyChildCapabilityById
    * def expectedCapability = childCapability
    Given path 'capabilities', expectedCapability.id
    When method get
    Then status 200
    And match response == expectedCapability
