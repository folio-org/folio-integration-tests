Feature: okapi facade tenant modules

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)' }
    * configure retry = { count: 10, interval: 5000 }
    # Okapi module id rule: the product name ends before the first '-' that is followed by a digit.
    * def toProduct = function(moduleId) { return moduleId.replace(/-\d.*$/, '') }

  @Positive
  Scenario: list modules enabled for the tenant
    Given path '_/proxy/tenants', testTenant, 'modules'
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response == '#[_ > 0]'
    # Without full=true each item carries only the module id, plus tags when the module has them.
    And match each response == { id: '#string', tags: '##array' }
    * def products = karate.map(response, md => toProduct(md.id))
    And match products contains ['mod-okapi-facade', 'mod-users-keycloak', 'mod-login-keycloak', 'mod-roles-keycloak']

  @Positive
  Scenario: list full module descriptors enabled for the tenant
    Given path '_/proxy/tenants', testTenant, 'modules'
    And param full = true
    And retry until responseStatus == 200
    When method GET
    Then status 200
    * def facadeModules = karate.filter(response, md => toProduct(md.id) == 'mod-okapi-facade')
    And match facadeModules == '#[1]'
    And match facadeModules[0] contains { id: '#string', name: '#string', provides: '#[_ > 0]' }
    * def okapiInterfaces = karate.filter(facadeModules[0].provides, i => i.id == 'okapi')
    And match okapiInterfaces == '#[1]'
    * def handlerPaths = karate.map(okapiInterfaces[0].handlers, h => h.pathPattern)
    And match handlerPaths contains ['/_/proxy/tenants/{tenantId}/modules', '/_/proxy/tenants/{tenantId}/interfaces']

  @Positive
  Scenario: find the module that provides an interface
    Given path '_/proxy/tenants', testTenant, 'modules'
    And param provide = 'okapi'
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response == '#[1]'
    And match response[0].id == '#regex mod-okapi-facade-\\d.*'
