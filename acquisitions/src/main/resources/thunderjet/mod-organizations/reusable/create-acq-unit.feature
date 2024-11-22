@ignore
Feature: Create ACQ Unit
  # parameters: id?, name, code, status?

  Background:
    * url baseUrl

  Scenario: createAcqUnit
    * def newId = callonce uuid
    * def id = karate.get('id', newId)
    Given path '/acquisitions-units-storage/units'
    And request
      """
      {
        id: '#(id)',
        name: '#(name)',
        isDeleted: '#(isDeleted)',
        protectRead: '#(protectRead)',
        protectCreate: '#(protectCreate)',
        protectUpdate: '#(protectUpdate)',
        protectDelete: '#(protectDelete)'
      }
      """
    When method POST
    Then status 201
