Feature: Tenant utils

  Background:
    * url baseUrl
    * configure readTimeout = 300000
    * configure retry = { count: 2, interval: 5000 }

  @create
  Scenario: createTenant
    Given path '_/proxy/tenants'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = adminToken
    And request { id: '#(testUser.tenant)', name: 'Test tenant', description: 'Tenant for test purpose' }
    When method POST
    Then status 201

  @install
  Scenario: install modules for tenant
    * def response = call read('classpath:common/module.feature@GetModuleById') modules
    * def modulesWithVersions = $response[*].response[-1].id
    * def enabledModules = karate.map(modulesWithVersions, function(x) {return {id: x, action: 'enable'}})
    * print enabledModules

    Given path '_/proxy/tenants', tenant, 'install'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = adminToken
    And retry until responseStatus == 200
    And request enabledModules
    When method POST
    Then status 200

  @delete
  Scenario: deleteTenant
    Given path '_/proxy/tenants', tenant
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = adminToken
    When method DELETE
    Then status 204
