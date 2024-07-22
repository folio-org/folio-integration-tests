Feature: Create instance

  Background:
    * url baseUrl

  Scenario: createInstance
    Given path 'inventory/instances'
    And request
      """
      {
        "id": "#(id)",
        "title": "#(title)",
        "instanceTypeId": "#(instanceTypeId)",
        "source": "FOLIO"
      }
      """
    When method POST
    Then status 201
