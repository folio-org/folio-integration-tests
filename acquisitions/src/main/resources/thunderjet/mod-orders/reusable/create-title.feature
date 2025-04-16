@ignore
Feature: Create a title

  Background:
    * url baseUrl

  @title
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

  @instance
  Scenario: Create title for instance and add annotation for both to distinguish instanceId + poLineId + title
    Given path 'orders/titles'
    And request
    """
    {
      id: "#(id)",
      instanceId: "#(instanceId)",
      title: "#(title)",
      poLineId: "#(poLineId)"
    }
    """
    When method POST
    Then status 201
