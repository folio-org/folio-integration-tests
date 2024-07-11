Feature: Search resource
  Background:
    * url baseUrl

  @searchWork
  Scenario: Search work resource
    Given path 'search/linked-data/works'
    And param query = query
    And param limit = 10
    And param offset = 0
    And retry until response.totalRecords > 0  && (!validateInstance || response.content[0].instances.length > 0)
    When method GET
    Then status 200
    * def response = $