@ignore
Feature: Create instance type

  Background:
    * url baseUrl

  Scenario: createInstanceType
    Given path 'instance-types'
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
