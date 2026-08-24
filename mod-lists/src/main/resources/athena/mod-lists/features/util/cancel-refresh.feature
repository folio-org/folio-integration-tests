Feature: Cancel a refresh
  Background:
    * url baseUrl

  Scenario: Cancel a refresh
    Given path 'lists', listId, 'refresh'
    When method DELETE
    Then status 204

    Given path 'lists', listId
    When method GET
    Then status 200
    And match $.inProgressRefresh == '#notpresent'
