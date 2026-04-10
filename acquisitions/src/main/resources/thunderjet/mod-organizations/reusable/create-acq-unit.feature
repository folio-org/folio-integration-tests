@ignore
Feature: Create ACQ Unit
  # parameters: id?, name, isDeleted, protectRead, protectCreate, protectUpdate, protectDelete

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create ACQ Unit
    * def newId = callonce uuid
    * def id = karate.get('id', newId)
    Given path '/acquisitions-units/units'
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
