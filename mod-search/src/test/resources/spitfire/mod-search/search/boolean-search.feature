Feature: Tests for boolean operators: AND, OR, NOT

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = {'Content-Type': 'application/json', 'Accept': '*/*', 'x-okapi-token': #(okapitoken)}

  Scenario Outline: Can use boolean operation <operation> for search
    Given path '/search/instances'
    And param query = '<query>'
    When method GET
    Then status 200
    Then match response.totalRecords == 1
    Then match response.instances[0].id == '#(webSemanticInstance)'
    Examples:
      | operation            | query                                                                                         |
      | AND                  | title all "web semantic" AND contributors all "Antoniou, Grigoris"                            |
      | OR                   | title all "web semantic" OR subjects any "semantic networks"                                  |
      | OR (single property) | hrid==("inst000000000022" OR "inst007")                                                       |
      | NOT                  | title all "web semantic" NOT discoverySuppress==false                                         |
      | AND OR NOT           | title all "web semantic" AND instanceTags==("book" OR "electronic book") NOT languages=="fre" |
      | brackets             | (instanceTags=="book" OR languages=="fre") AND hrid=="inst000000000022"                       |