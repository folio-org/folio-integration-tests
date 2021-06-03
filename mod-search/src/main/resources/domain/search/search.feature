Feature: Search API tests

  Background:
    * url baseUrl
    * configure headers = baseHeaders

  Scenario: Search should return instance by title
    Given path '/search/instances'
    And param query = 'title all "web of metaphor karate"'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.instances[0].id == '7e18b615-0e44-4307-ba78-76f3f447041c'
    Then match response.instances[0].title == "The web of metaphor karate :studies in the imagery of Montaigne's Essais /by Carol Clark."