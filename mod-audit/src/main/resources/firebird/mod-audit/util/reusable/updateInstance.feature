@ignore
Feature: Update inventory instance

  Background:
    * url baseUrl

  Scenario: UpdateInstance
    Given path 'inventory/instances/' + instanceId
    And request instance
    When method PUT
    Then status 204
