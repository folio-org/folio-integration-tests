Feature: Run synchronous FQM query
  # parameters: entityTypeId, fqlQuery, fields
  # returns: content, totalRecords
  Background:
    * url baseUrl

  Scenario: Run synchronous FQM query
    Given path 'query'
    And params { entityTypeId: '#(entityTypeId)', query: '#(fqlQuery)', fields: '#(fields)', limit: 100 }
    When method GET
    Then status 200
    * def content = $.content
    * def totalRecords = parseInt(response.totalRecords)
