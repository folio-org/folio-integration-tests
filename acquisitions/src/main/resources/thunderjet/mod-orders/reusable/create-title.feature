@ignore
Feature: Create a title

  Background:
    * url baseUrl

  Scenario: Create title
    * def instanceId = karate.get('instanceId', null)
    Given path 'orders/titles'
    And request
    """
    {
      id: "#(titleId)",
      title: "Sample Title",
      poLineId: "#(poLineId)",
      instanceId: "#(instanceId)",
    }
    """
    When method POST
    Then status 201
