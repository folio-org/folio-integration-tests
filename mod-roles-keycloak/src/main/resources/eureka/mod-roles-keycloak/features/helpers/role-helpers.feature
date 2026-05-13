Feature: Shared role helpers for mod-roles-keycloak Karate tests

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @ignore @createRole
  Scenario: createRole
    * def roleRequest =
      """
      {
        "name": "#(roleName)",
        "description": "#(roleDescription)",
        "type": "#(roleType)"
      }
      """
    Given path 'roles'
    And request roleRequest
    When method post
    Then status 201
    And match response.id == '#uuid'
    And match response.name == roleName
    And match response.description == roleDescription
    And match response.type == roleType
    * def roleId = response.id
    * def role = response
