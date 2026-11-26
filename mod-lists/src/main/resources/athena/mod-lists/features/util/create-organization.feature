Feature: Create organization
  # parameters: id, name, code, status?
  Background:
    * url baseUrl

  Scenario: Create organization
    * def status = karate.get('status', 'Active')
    Given path 'organizations/organizations'
    And request { id: '#(id)', name: '#(name)', code: '#(code)', status: '#(status)' }
    When method POST
    Then status 201
