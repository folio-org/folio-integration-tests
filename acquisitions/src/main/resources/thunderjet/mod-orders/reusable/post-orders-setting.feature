@ignore
Feature: Create an orders-storage setting
  # parameters: key, value, headersAdmin

  Background:
    * print karate.info.scenarioName
    * url baseUrl

  Scenario: Post Orders Setting
    Given path 'orders-storage/settings'
    And headers headersAdmin
    And request { key: '#(key)', value: '#(value)' }
    When method POST
    Then status 201