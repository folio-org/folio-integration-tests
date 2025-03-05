Feature: Consortium object in api tests

  Background:
    * url baseUrl
    * configure retry = { count: 20, interval: 40000 }
    * configure headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}

  # Parameters: Tenant tenant, User adminUser, String token, Consortium confortium Result: void
  @SetupConsortia
  Scenario: Create a consortia
    * def consortiumName = tenant.name +  'name for test'

    # create a consortia
    Given path 'consortia'
    And headers {'x-okapi-token': '#(token)', 'x-okapi-tenant': '#(tenant.name)'}
    And request { id: '#(confortium.id)', name: '#(consortiumName)' }
    And retry until responseStatus == 201
    When method POST
    And match response == { id: '#(confortium.id)', name: '#(consortiumName)' }

  # Parameters: Tenant tenant, User adminUser, String token, String code, String name, Boolean isCentral Result: void
  @SetupTenantForConsortia
  Scenario: Create tenant for consortia
    * def name = tenant.name + ' tenants name'

    # post a tenant
    Given path 'tenants', confortium.id
    And headers {'x-okapi-token': '#(token)', 'x-okapi-tenant': '#(tenant.name)'}
    And request { id: '#(tenant.id)', code: '#(code)', name: '#(name)', isCentral: '#(isCentral)' }
    When method POST
    Then status 201
    And match response == { id: '#(tenant.id)', code: '#(code)', name: '#(name)', isCentral: '#(isCentral)', isDeleted: false }