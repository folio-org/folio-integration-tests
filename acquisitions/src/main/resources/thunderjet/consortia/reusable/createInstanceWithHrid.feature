@ignore
Feature: Create instance

  Background:
    * url baseUrl

  Scenario: createInstanceWithHrid
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
