Feature: Create expense class
  # parameters: id, name, code
  Background:
    * url baseUrl

  Scenario: Create expense class
    Given path 'finance/expense-classes'
    And request { id: '#(id)', name: '#(name)', code: '#(code)' }
    When method POST
    Then status 201
