Feature: Create instance status

  Background:
    * url baseUrl

  Scenario: createInstanceStatus
    Given path 'instance-statuses'
    And request
    """
    {
      "id": "#(id)",
      "code": "#(code)",
      "name": "#(code)",
      "source": "apiTests"
    }
    """
    When method POST
    Then status 201
