Feature: Module

  Background:
    * url kongUrl
    * configure report = { showLog: false, showAllSteps: false }


  # prototypeTenant is to get applications of this tenant
  # modules parameter is optional. It is just needed only to check that these modules exist
  # Parameters: String prototypeTenant, String[] modules, String token Result: void
  @GetModuleById
  Scenario: get module by id
    * def modulesUrl = '/entitlements/' + prototypeTenant + '/applications'
    * print 'Exprecting modules: ' + modules
    Given path modulesUrl
    And header Content-Type = 'application/json'
    And header Accept = 'application/json'
    And header x-okapi-token = token
    And header x-okapi-tenant = prototypeTenant
    When method GET
    Then status 200
    * def uiModules = get response.applicationDescriptors[*].uiModules[*].name
    * def modules = get response.applicationDescriptors[*].modules[*].name
    * def receivedModules = modules + uiModules
    * print 'modules: ' + receivedModules
    Then match response.applicationDescriptors[*].modules[*].name contains modules

