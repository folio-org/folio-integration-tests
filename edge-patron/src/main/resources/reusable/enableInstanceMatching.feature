@ignore
Feature: Enable Instance Matching

  Background:
    * url baseUrl

  Scenario: enableInstanceMatching
    Given path 'orders-storage/settings'
    And param query = 'key==disableInstanceMatching'
    When method GET
    Then status 200
    * def setting = $.settings[0]
    * set setting.value = "{\"isInstanceMatchingDisabled\":false}"
    * def settingId = $.settings[0].id

    Given path 'orders-storage/settings', settingId
    And request setting
    When method PUT
    Then status 204
    * call pause 40000