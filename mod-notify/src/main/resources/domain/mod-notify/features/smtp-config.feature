Feature: Configure smtp
  Background:
    * url baseUrl
    * def configs = read('samples/smtp-configuration.json')

  Scenario Outline: POST SMTP configuration
    Given path 'configurations/entries'
    And request {'module': '#(module)', 'configName': '#(configName)', 'code': '#(code)', 'default': true, 'value': '#(value)'}
    When method POST
    Then status 201

    Examples:
     | configs |