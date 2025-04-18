Feature: tests for ListSets verb

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl

  Scenario: get ListSets
    Given param verb = 'ListSets'
    When method GET
    Then status 200
    Then match response //responseDate == checkDateByRegEx
    Then match response //setSpec == 'all'
    * match response count(//set) == 1