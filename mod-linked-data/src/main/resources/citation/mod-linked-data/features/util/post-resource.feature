Feature: Post a resource
  Background:
    * url baseUrl
  Scenario: Post a resource
    Given path 'resource'
    And request resourceRequest
    When method POST
    Then status 200
    * def response = $