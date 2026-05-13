Feature: Shared lookup helpers for mod-roles-keycloak Karate tests

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @ignore @getCapabilityByPermission
  Scenario: getCapabilityByPermission
    Given path 'capabilities'
    And param query = 'permission=="' + capabilityPermission + '"'
    When method get
    Then status 200
    And match response.capabilities == '#[1]'
    * def capability = response.capabilities[0]

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
