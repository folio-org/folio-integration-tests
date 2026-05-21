@ignore
Feature: Update an orders-storage setting by id
  # parameters: setting (full object with id, key, value), headersAdmin

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Put Orders Setting
    Given path 'orders-storage/settings', setting.id
    And headers headersAdmin
    And request setting
    When method PUT
    Then status 204