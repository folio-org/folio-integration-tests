@ignore
Feature: Delete instance
  # parameters: id

  Background:
    * url baseUrl

  Scenario: deleteInstance
    Given path 'inventory/instances', id
    When method DELETE
    Then status 204