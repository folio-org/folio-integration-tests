Feature: Post new list
  Background:
    * url baseUrl
  Scenario: Post new list
    * def entityTypeId = listRequest.entityTypeId
    Given path 'lists'
    And request listRequest
    When method POST
    Then status 201
    * def listId = $.id
