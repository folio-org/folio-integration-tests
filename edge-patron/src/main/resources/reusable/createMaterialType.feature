@ignore
Feature: Create material type

  Background:
    * url baseUrl

  Scenario: createMaterialType
    Given path 'material-types'
    And request
    """
    {
      "id": "#(id)",
      "name": "#(name)"
    }
    """
    When method POST
    Then status 201
