Feature: Create a title

  Background:
    * url baseUrl

  Scenario: Create title
    Given path 'orders/titles'
    And request
    """
    {
      id: "#(titleId)",
      title: "Sample Title",
      poLineId: "#(poLineId)"
    }
    """
    When method POST
    Then status 201
