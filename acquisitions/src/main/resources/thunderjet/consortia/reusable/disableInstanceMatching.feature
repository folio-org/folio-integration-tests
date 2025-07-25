@ignore
Feature: Disable Instance Matching

  Background:
    * url baseUrl

  Scenario: disableInstanceMatching
    Given path 'configurations/entries'
    And request
      """
      {
        "id": "#(id)",
        "value": "{\"isInstanceMatchingDisabled\":true}",
        "module": "ORDERS",
        "configName": "disableInstanceMatching"
      }
      """
    When method POST
    Then status 201