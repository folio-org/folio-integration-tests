@ignore
Feature: Delete resource
  # resourcePath, resourceId, tenantId

  Scenario: Delete resource
    * url baseUrl
    * def tenant = karate.get('tenantId', testTenant);
    Given path resourcePath, resourceId
    And header x-okapi-tenant = tenant
    When method DELETE
    Then status 204