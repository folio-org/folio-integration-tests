@ignore
Feature: Create holding source

  Background:
    * url baseUrl

  Scenario: createHoldingSource
    Given path 'holdings-sources'
    And request
    """
    {
      "id": "#(id)",
      "name": "#(name)"
    }
    """
    When method POST
    Then status 201
