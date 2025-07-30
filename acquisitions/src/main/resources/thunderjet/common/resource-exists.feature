Feature: Check if resource exists by a provided field
  # resourcePath, queryKey, queryVal, tenantId

  Scenario: Check if resource exists
    * url baseUrl
    * def queryKey = karate.get('queryKey', 'id');
    Given path resourcePath
    And header x-okapi-tenant = tenantId
    And param query = queryKey + "=" + queryVal
    When method GET
    Then status 200
    * def result = response.totalRecords != 0