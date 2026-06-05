Feature: Consortium object in api tests

  Background:
    * url baseUrl
    # 20 retries × 30 s = 10 min max per polling step — Eureka tenant provisioning triggers
    # heavy async Kafka/Keycloak work and regularly needs more than the previous 5-min window.
    * configure retry = { count: 20, interval: 30000 }
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
    # Retry on transient 5xx — Kafka-driven system-user / custom-field provisioning may not
    # have finished yet immediately after consortium or tenant entitlement creation.
    Given path 'consortia', consortiumId, 'tenants'
    And param adminUserId = consortiaAdmin.id
    And headers {'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)'}
    And request { id: '#(tenant)', code: '#(code)', name: '#(name)', isCentral: '#(isCentral)' }
    And retry until responseStatus == 201
    When method POST
    Then status 201
    And match response == { id: '#(tenant)', code: '#(code)', name: '#(name)', isCentral: '#(isCentral)', isDeleted: false }

    # Poll until the tenant's async setup (shadow users, identity providers, cross-tenant
    # Keycloak federation) has fully completed before returning to the caller.
    Given path 'consortia', consortiumId, 'tenants', tenant
    And headers {'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)'}
    And retry until response.setupStatus == 'COMPLETED'
    When method GET
    Then status 200
    And match response.id == tenant
    And match response.setupStatus == 'COMPLETED'
