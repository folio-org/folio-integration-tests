Feature: mod-circulation primary test scenario

  Background:
    * url baseUrl
    * callonce login { tenant: 'diku', name: 'diku_admin', password: 'admin' }
    * def headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': '*/*'  }

  Scenario: Get available requests
    Given path 'circulation/requests'
    And headers headers
    When method GET
    Then status 200