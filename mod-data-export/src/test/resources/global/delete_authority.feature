Feature: calls to delete authority

  Background:
    * url baseUrl

    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testTenant)' }

  @DeleteAuthority
  Scenario: delete authority by id
    Given path 'authority-storage/authorities/', authorityId
    When method DELETE
    Then status 204
