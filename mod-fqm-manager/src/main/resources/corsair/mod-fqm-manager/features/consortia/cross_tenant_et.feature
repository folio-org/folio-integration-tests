Feature: Verify cross-tenant ET definition in mod-fqm-manager

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure retry = { count: 5, interval: 20000 }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

  @Positive
  Scenario: Retrieve cross-tenant ET definition and verify flag
    Given path 'entity-types'
    When method GET
    Then status 200
    # Retry up to 5 times
    And retry until response.entityTypes contains {crossTenantQueriesEnabled: true }
    And match response.entityTypes contains deep {crossTenantQueriesEnabled: true }