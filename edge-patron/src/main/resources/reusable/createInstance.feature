@ignore
Feature: Create instance

  Background:
    * url baseUrl

  Scenario: createInstance
    * def identifiers = karate.get('identifiers', [])

    Given path 'inventory/instances'
    And request
      """
      {
        "id": "#(id)",
        "title": "#(title)",
        "instanceTypeId": "#(instanceTypeId)",
        "source": "FOLIO",
        "identifiers": "#(identifiers)"
      }
      """
    When method POST
    Then status 201
