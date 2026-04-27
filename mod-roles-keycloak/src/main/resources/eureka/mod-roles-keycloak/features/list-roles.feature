Feature: list roles

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  Scenario: verify roles endpoint is reachable
    Given path 'roles'
    When method get
    Then status 200
    And match response.roles == '#array'
    And match response.totalRecords == '#number'
