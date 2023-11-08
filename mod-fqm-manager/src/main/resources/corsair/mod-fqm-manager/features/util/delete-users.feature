Feature: Delete users
  Background:
    * url baseUrl
  Scenario: Delete users
    Given path 'users/' + userId
    When method DELETE
    Then status 204
