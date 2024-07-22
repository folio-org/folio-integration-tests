Feature: CRUD operations on a resource
  Background:
    * url baseUrl

  @getResource
  Scenario: Get a resource
    Given path 'resource/' + id
    When method Get
    Then status 200
    * def response = $

  @postResource
  Scenario: Post a resource
    Given path 'resource'
    And request resourceRequest
    When method POST
    Then status 200
    * def response = $