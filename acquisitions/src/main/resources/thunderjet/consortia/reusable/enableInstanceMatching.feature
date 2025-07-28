@ignore
Feature: Enable Instance Matching

  Background:
    * url baseUrl

  Scenario: enableInstanceMatching
    Given path 'configurations/entries'
    And param query = 'configName==disableInstanceMatching'
    When method GET
    Then status 200
    * def config = $.configs[0]
    * set config.value = "{\"isInstanceMatchingDisabled\":false}"
    * def configId = $.configs[0].id

    Given path 'configurations/entries', configId
    And request config
    When method PUT
    Then status 204
    * call pause 40000