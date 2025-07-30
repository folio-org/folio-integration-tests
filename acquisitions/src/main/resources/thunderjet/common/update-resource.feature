@ignore
Feature: Update resource
  # resourcePath, resourceId, tenantId

  Background:
    * url baseUrl
    * def tenant = karate.get('tenantId', testTenant);

  Scenario: updateResource
    Given path resourcePath, resourceId
    And header x-okapi-tenant = tenant
    When method GET
    Then status 200
    * def resource = response

    Given path resourcePath, resourceId
    And header x-okapi-tenant = tenant
    And request resource
    When method PUT
    Then status 204