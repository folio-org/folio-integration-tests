Feature: Create fiscal year
  # parameters: id, code, periodStart, periodEnd
  Background:
    * url baseUrl

  Scenario: Create fiscal year
    * def series = (code + '').replace(/\d+$/, '')
    Given path 'finance/fiscal-years'
    And request { id: '#(id)', name: '#(code)', code: '#(code)', series: '#(series)', periodStart: '#(periodStart)', periodEnd: '#(periodEnd)' }
    When method POST
    Then status 201
