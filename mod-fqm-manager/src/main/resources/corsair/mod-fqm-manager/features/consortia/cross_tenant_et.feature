Feature: Verify cross-tenant ET definition in mod-fqm-manager

  Background:
    * url baseUrl
    * call read(login) consortiaAdmin
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

  @Positive
  Scenario: Retrieve cross-tenant ET definition and verify flag
    Given path 'entity-types'
    When method GET
    Then status 200
    And match response.entityTypes contains { label: "Instances", crossTenantQueriesEnabled: true }