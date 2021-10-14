Feature: Create circulation rule

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

  @CreateCirculationRule
  Scenario: Create circulation rule
    Given path 'circulation/rules'
    And request { rulesAsText: '#(rulesAsText)' }
    When method PUT
    Then status 204