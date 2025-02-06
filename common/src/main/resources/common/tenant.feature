Feature: Tenants

  Background:
    * url baseUrl
    * configure retry = { count: 2, interval: 5000 }
    * configure readTimeout = 3000000
    * call login admin

  @create
  Scenario: createTenant
    Given path '_/proxy/tenants'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And request { id: '#(__arg.tenant)', name: 'Test tenant', description: 'Tenant for test purpose' }
    When method POST
    Then status 201

  @install
  Scenario: install tenant for modules

    * def response = call read('classpath:common/module.feature') __arg.modules

    * def modulesWithVersions = $response[*].response[-1].id
    * def enabledModules = karate.map(modulesWithVersions, function(x) {return {id: x, action: 'enable'}})
    * print enabledModules
    # tenantParams should be declared in your karate-config file as following tenantParams: {loadReferenceData : true}
    * def loadReferenceRecords = karate.get('tenantParams', {'loadReferenceData': false}).loadReferenceData

    Given path '_/proxy/tenants', __arg.tenant, 'install'
    And param tenantParameters = 'loadSample=false,loadReference=' + loadReferenceRecords
    And param depCheck = __arg.depCheck || karate.get('checkDepsDuringModInstall', 'true')
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And retry until responseStatus == 200
    And request enabledModules
    When method POST
    Then status 200

  @disable
  Scenario: disable mod-authtoken module
    Given path '_/proxy/tenants', __arg.tenant, 'modules'
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    When method GET
    Then status 200
    * def modAuthtoken = karate.filter(response, function(x){ return x.id.startsWith('mod-authtoken') })
    * set modAuthtoken[0].action = 'disable'

    Given path '_/proxy/tenants', __arg.tenant, 'install'
    * def loadReferenceRecords = karate.get('tenantParams', {'loadReferenceData': false}).loadReferenceData
    And param tenantParameters = 'loadSample=false,loadReference=' + loadReferenceRecords
    And param depCheck = __arg.depCheck || karate.get('checkDepsDuringModInstall', 'true')
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And retry until responseStatus == 200
    And request modAuthtoken
    When method POST
    Then status 200

  @delete
  Scenario: deleteTenant
    Given path '_/proxy/tenants', __arg.tenant
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    When method DELETE
    Then status 204
