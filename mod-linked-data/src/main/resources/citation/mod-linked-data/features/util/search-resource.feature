Feature: Search resource
  Background:
    * url baseUrl
  Scenario: Search resource
    Given path 'search/bibframe'
    And param query = queryParam
    And param limit = limitParam
    And param offset = offsetParam
    When method GET
    Then status 200
    * def response = $