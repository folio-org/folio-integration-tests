Feature: Create an instance

  Background:
    * url baseUrl

  Scenario: Create instance
    Given path 'inventory/instances'
    And request
    """
    {
      "id": "#(instanceId)",
      "source": "FOLIO",
      "title": "#(title)",
      "instanceTypeId": "#(instanceTypeId)"
    }
    """
    When method POST
    Then status 201
