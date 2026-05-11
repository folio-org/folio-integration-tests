Feature: Capability helper functions

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @ignore @getCapabilityByPermission
  Scenario: getCapabilityByPermission
    Given path 'capabilities'
    And param query = 'permission=="' + capabilityPermission + '"'
    When method get
    Then status 200
    And match response.capabilities == '#[1]'
    * def capability = response.capabilities[0]
