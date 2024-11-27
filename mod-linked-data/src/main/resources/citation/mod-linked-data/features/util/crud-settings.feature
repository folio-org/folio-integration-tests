Feature: CRUD operations on settings
  Background:
    * url baseUrl

  @getSettings
  Scenario: Get settings
    Given path 'settings/entries'
    And param query = query
    When method GET
    Then status 200
    * def response = $

  @putSetting
  Scenario: Put a setting
    Given path 'settings/entries/' + id
    And request settingRequest
    When method PUT
    Then status 200
    * def response = $
