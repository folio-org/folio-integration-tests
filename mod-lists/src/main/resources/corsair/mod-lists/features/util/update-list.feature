Feature: Update existing list
  Background:
    * url baseUrl
  Scenario: Update existing list (listId) with contents (listRequest)
    Given path 'lists', listId
    And request listRequest
    When method PUT
    Then status 200
