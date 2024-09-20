Feature: Delete resource
  # resourcePath, resourceId, tenantId, statusCode

  Scenario: Delete resource
    * url baseUrl
    * def tenant = karate.get('tenantId', testTenant);
    * def expectedCode = karate.get('statusCode', 204);
    Given path resourcePath, resourceId
    And header x-okapi-tenant = tenant
    When method DELETE
    Then status expectedCode