Feature: Delete list
  Background:
    * url baseUrl

  Scenario: Delete list
    Given path 'lists/' + listId
    When method DELETE
    Then status 204

    Given path 'lists/' + listId
    When method GET
    Then status 404