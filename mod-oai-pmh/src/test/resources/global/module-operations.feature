Feature: Module

  Background:
    * url baseUrl

  @enableModule
  Scenario: enables module for tenant
    Given path '_/proxy/tenants', tenant, 'modules'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And request
    """
    {
      'id' : '#(moduleId)'
    }
    """
    When method POST
    Then status 201

  @deleteModule
  Scenario: removes module for tenant
    Given path '_/proxy/tenants', tenant, 'modules', moduleId
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204

  @getModuleIdByName
  Scenario: finds module by name and returns its id
    Given path '_/proxy/tenants', tenant, 'modules'
    And param filter = moduleName
    And header Accept = 'application/json'
    When method GET
    Then status 200