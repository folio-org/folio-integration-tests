Feature: Modules

  Background:
    * url baseUrl

  @disable
  Scenario: disable modules
    * def response = call read('classpath:common/module.feature') __arg.modules
    * def modulesWithVersions = $response[*].response[-1].id
    * def disabledModules = karate.map(modulesWithVersions, function(x) {return {id: x, action: 'disable'}})
    * print disabledModules

    Given path '_/proxy/tenants', __arg.tenant, 'install'
    * def loadReferenceRecords = karate.get('tenantParams', {'loadReferenceData': false}).loadReferenceData
    And param tenantParameters = 'loadSample=false,loadReference=' + loadReferenceRecords
    And param depCheck = __arg.depCheck || karate.get('checkDepsDuringModInstall', 'true')
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And retry until responseStatus == 200
    And request disabledModules
    When method POST
    Then status 200

  @install
  Scenario: install modules from response
    * def loadReferenceRecords = karate.get('tenantParams', {'loadReferenceData': false}).loadReferenceData
    * def response = __arg.disabledModules.response
    * set response $[*].action = 'enable'

    Given path '_/proxy/tenants', __arg.tenant, 'install'
    And param tenantParameters = 'loadSample=false,loadReference=' + loadReferenceRecords
    And param depCheck = __arg.depCheck || karate.get('checkDepsDuringModInstall', 'true')
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = okapitoken
    And retry until responseStatus == 200
    And request response
    When method POST
    Then status 200

