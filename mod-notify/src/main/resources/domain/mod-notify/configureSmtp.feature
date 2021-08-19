Feature: configure smtp

  Background:
    * url baseUrl

  Scenario : configure smtp
    Given path 'configurations/entries'
    And request #(config)
    When method POST
    Then status 201
