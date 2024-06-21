Feature: Search resource & validate response
  Background:
    * url baseUrl
  Scenario: Search work resource & validate response
    Given path 'search/bibframe'
    And param query = query
    And param limit = 10
    And param offset = 0
    And retry until response.totalRecords > 0 && response.content[0].instances.length > 0
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.content[0] contains { id: '#(expectedWorkId)' }
    Then match response.content[0].instances[0] contains { id: '#(expectedInstanceId)' }
    * def response = $