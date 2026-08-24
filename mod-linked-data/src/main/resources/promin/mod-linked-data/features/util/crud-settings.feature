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
    Then status 204

  @postSetting
  Scenario: Post a setting
    Given path 'settings/entries/'
    And request settingRequest
    When method POST
    Then status 204

  @getSetting
  Scenario: Get a setting
    Given path 'settings/entries/' + id
    When method GET
    Then status 200
    * def response = $
