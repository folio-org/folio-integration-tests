@ignore
Feature: Delete instance
  # parameters: id

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Delete instance
    Given path 'inventory/instances', id
    When method DELETE
    Then status 204