Feature: list timers

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*', 'x-okapi-tenant': '#(testTenant)' }

  @Positive
  Scenario: verify scheduler timers endpoint is reachable
    Given path 'scheduler/timers'
    When method get
    Then status 200
    And match response.timerDescriptors == '#array'
    And match response.totalRecords == '#number'
