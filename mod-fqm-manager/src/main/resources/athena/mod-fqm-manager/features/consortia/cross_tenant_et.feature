Feature: Verify cross-tenant ET definition in mod-fqm-manager

  Background:
    * url baseUrl
    * call login consortiaAdmin
    * configure retry = { count: 5, interval: 20000 }
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(centralTenant)', 'Accept': 'application/json' }

  @Positive
  Scenario: Retrieve cross-tenant ET definition and verify flag
    * def hasCrossTenantEntityType = function() { return responseStatus == 200 && response.entityTypes && karate.filter(response.entityTypes, function(entityType) { return entityType.crossTenantQueriesEnabled == true }).length > 0 }
    Given path 'entity-types'
    And retry until hasCrossTenantEntityType()
    When method GET
    Then status 200
    And match response.entityTypes contains deep {crossTenantQueriesEnabled: true }
