Feature: Create fund
  # parameters: id, code, name, ledgerId
  Background:
    * url baseUrl

  Scenario: Create fund
    Given path 'finance/funds'
    And request { fund: { id: '#(id)', code: '#(code)', name: '#(name)', ledgerId: '#(ledgerId)', fundStatus: 'Active' } }
    When method POST
    Then status 201
