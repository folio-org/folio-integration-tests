@ignore
Feature: Create holding

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create holding
    Given path 'holdings-storage/holdings'
    And request
      """
      {
        id: "#(id)",
        instanceId: "#(instanceId)",
        permanentLocationId: "#(locationId)",
        sourceId : "#(sourceId)"
      }
      """
    When method POST
    Then status 201
