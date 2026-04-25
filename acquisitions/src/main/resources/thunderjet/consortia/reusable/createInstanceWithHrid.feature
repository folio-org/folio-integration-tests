@ignore
Feature: Create instance with hrid

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Create instance with hrid
    Given path 'inventory/instances'
    And request
      """
      {
        "id": "#(id)",
        "title": "#(title)",
        "instanceTypeId": "#(instanceTypeId)",
        "hrid": "#(hrid)",
        "source": "FOLIO"
      }
      """
    When method POST
    Then status 201
