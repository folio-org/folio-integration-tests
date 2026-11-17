Feature: okapi facade tenant interfaces

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)' }
    * configure retry = { count: 10, interval: 5000 }

  @Positive
  Scenario: list interfaces provided to the tenant
    Given path '_/proxy/tenants', testTenant, 'interfaces'
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response == '#[_ > 0]'
    # Without full=true each item carries only the interface id and version.
    And match each response == { id: '#string', version: '#string' }
    * def interfaceIds = karate.map(response, i => i.id)
    And match interfaceIds contains ['okapi', 'users-keycloak', 'login', 'roles']

  @Positive
  Scenario: list full interface descriptors provided to the tenant
    Given path '_/proxy/tenants', testTenant, 'interfaces'
    And param full = true
    And retry until responseStatus == 200
    When method GET
    Then status 200
    * def okapiInterfaces = karate.filter(response, i => i.id == 'okapi')
    And match okapiInterfaces == '#[1]'
    * def handlerPaths = karate.map(okapiInterfaces[0].handlers, h => h.pathPattern)
    And match handlerPaths contains ['/_/proxy/tenants/{tenantId}/modules', '/_/proxy/tenants/{tenantId}/interfaces']

  @Positive
  Scenario: list only system interfaces provided to the tenant
    Given path '_/proxy/tenants', testTenant, 'interfaces'
    And param full = true
    And param type = 'system'
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response == '#[_ > 0]'
    And match each response contains { interfaceType: '#regex (?i)system' }
    * def interfaceIds = karate.map(response, i => i.id)
    And match interfaceIds contains '_tenant'
    And match interfaceIds !contains 'okapi'

  @Positive
  Scenario: list only proxy interfaces provided to the tenant
    Given path '_/proxy/tenants', testTenant, 'interfaces'
    And param type = 'proxy'
    And retry until responseStatus == 200
    When method GET
    Then status 200
    And match response == '#[_ > 0]'
    * def interfaceIds = karate.map(response, i => i.id)
    And match interfaceIds contains 'okapi'
    And match interfaceIds !contains '_tenant'
