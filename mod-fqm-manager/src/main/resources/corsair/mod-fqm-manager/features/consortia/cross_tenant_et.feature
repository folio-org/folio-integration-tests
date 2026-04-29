Feature: Verify cross-tenant ET definition in mod-fqm-manager

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure retry = { count: 5, interval: 20000 }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }
    * def instanceEntityTypeId = '6b08439b-4f8e-4468-8046-ea620f5cfb74'

  @Positive
  Scenario: Retrieve cross-tenant Instances ET definition and verify flag
    Given path 'entity-types', instanceEntityTypeId
    When method GET
    Then status 200
    And match response.id == instanceEntityTypeId
    And match response.crossTenantQueriesEnabled == true
