Feature: Consortium object in api tests

  Background:
    * url baseUrl
    * configure retry = { count: 20, interval: 40000 }
    * configure headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}

  @SetupConsortia
  Scenario: Create a consortia
    * def consortiumName = tenant +  'name for test'

    # create a consortia
    Given path 'consortia'
    And headers { 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)' }
    And request { id: '#(consortiumId)', name: '#(consortiumName)' }
    And retry until responseStatus == 201
    When method POST
    And match response == { id: '#(consortiumId)', name: '#(consortiumName)' }

  @SetupTenantForConsortia
  Scenario: Create tenant for consortia
    * def name = tenant + ' tenants name'

    # post a tenant
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And headers {'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)'}
    And request { id: '#(tenant)', code: '#(code)', name: '#(name)', isCentral: '#(isCentral)' }
    When method POST
    Then status 201
    And match response == { id: '#(tenant)', code: '#(code)', name: '#(name)', isCentral: '#(isCentral)', isDeleted: false }