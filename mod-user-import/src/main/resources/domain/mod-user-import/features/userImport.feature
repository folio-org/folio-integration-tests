Feature: Template engine

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }

  Scenario: Import without users
    Given path 'user-import'
    And request
    """
    {
      "users": []
    }
    """
    When method POST
    Then status 422