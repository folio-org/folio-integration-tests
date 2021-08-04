Feature: Mod-tags integration tests

  Background:
    * url baseUrl

    * callonce login testUser
    * def okapiUserToken = okapitoken

    * def headersUser = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapiUserToken)', 'Accept': 'application/json'  }
    * configure headers = headersUser
    * def tag = read('classpath:samples/tag.json')

  Scenario: Test GET collection of tags
    Given path 'tags'
    When method GET
    Then status 200
    And match response.totalRecords == 2