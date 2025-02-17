Feature: Consortium object in api tests

  Background:
    * url kongUrl
    * configure retry = { count: 20, interval: 40000 }

  @SetupConsortia
  Scenario: Create a consortia
    * def consortiumName = tenant.name +  'name for test'

    # create a consortia
    Given path '/consortia'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(token)', 'x-okapi-tenant': '#(tenant.name)', 'Accept': 'application/json' }
    And request { id: '#(confortium.id)', name: '#(consortiumName)' }
    And retry until responseStatus == 201
    When method POST
    And match response == { id: '#(confortium.id)', name: '#(consortiumName)' }

  @SetupTenantForConsortia
  Scenario: Create tenant for consortia
    * def name = tenant.name + ' tenants name'

    # post a tenant
    Given path 'tenants/', confortium.id
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(token)', 'x-okapi-tenant': '#(tenant.name)', 'Accept': 'application/json' }
    And request { id: '#(tenant.id)', code: '#(code)', name: '#(name)', isCentral: '#(isCentral)' }
    When method POST
    Then status 201
    And match response == { id: '#(tenant.id)', code: '#(code)', name: '#(name)', isCentral: '#(isCentral)', isDeleted: false }