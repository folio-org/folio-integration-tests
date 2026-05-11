Feature: Read operations on capabilities

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: get capabilities collection
    # Read the capabilities collection and verify the response shape.
    Given path 'capabilities'
    When method get
    Then status 200
    And match response.capabilities == '#array'
    And match response.totalRecords == '#number'

  @Positive
  Scenario: get capabilities collection with limit
    # Read a limited capabilities collection and verify the number of returned records.
    * def limit = 2
    Given path 'capabilities'
    And param limit = limit
    When method get
    Then status 200
    And match response.capabilities == '#[2]'
    And assert response.capabilities.length == limit

  @Positive
  Scenario: get a capability by id
    # Resolve a known capability by permission name and capture its identifier.
    * def capabilityPermission = 'role-capabilities.collection.get'
    * def capabilityName = 'role-capabilities_collection.view'
    Given path 'capabilities'
    And param query = 'permission=="' + capabilityPermission + '"'
    When method get
    Then status 200
    And match response.capabilities == '#[1]'
    * def capability = response.capabilities[0]
    * def capabilityId = capability.id

    # Read the capability directly by ID and verify the values.
    Given path 'capabilities', capabilityId
    When method get
    Then status 200
    And match response.id == capabilityId
    And match response.action == 'view'
    And match response.type == 'data'
    And match response.dummyCapability == false
    And match response.name == capabilityName
    And match response.permission == capabilityPermission
    And match response.endpoints == '#[2]'
    And match response.endpoints contains { method: 'GET', path: '/roles/capabilities' }
    And match response.endpoints contains { method: 'GET', path: '/roles/{id}/capabilities' }
