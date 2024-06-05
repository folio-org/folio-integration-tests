Feature: Consortium object in api tests

  Background:
    * url baseUrl
    * configure retry = { count: 20, interval: 40000 }

  @SetupConsortia
  Scenario: Create a consortia
    * def consortiumName = tenant +  'name for test'

    # create a consortia
    Given path '/consortia'
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }
    And request { id: '#(consortiumId)', name: '#(consortiumName)' }
    And retry until responseStatus == 201
    When method POST
    And match response == { id: '#(consortiumId)', name: '#(consortiumName)' }

  @SetupTenantForConsortia
  Scenario: Create tenant for consortia
    * def tenant = karate.get('tenant')
    * def code = karate.get('code')
    * def name = tenant + ' tenants name'

    * def isCentral = karate.get('isCentral')

    # post a tenant
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And headers { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }
    And request { id: '#(tenant)', code: '#(code)', name: '#(name)', isCentral: '#(isCentral)' }
    When method POST
    Then status 201
    And match response == { id: '#(tenant)', code: '#(code)', name: '#(name)', isCentral: '#(isCentral)', isDeleted: false }