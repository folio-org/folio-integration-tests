Feature: Create batch group
  # parameters: id, name
  Background:
    * url baseUrl

  Scenario: Create batch group
    Given path 'batch-groups'
    And request { id: '#(id)', name: '#(name)' }
    When method POST
    Then status 201
