Feature: tests for ListIdentifiers verb

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl

  # Happy path cases

  Scenario Outline: get ListIdentifiers <prefix>
    Given param verb = 'ListIdentifiers'
    And param metadataPrefix = <prefix>
    And param set = 'all'
    When method GET
    Then status 200
    Then match response //responseDate == checkDateByRegEx
    * match response count(//header) == 10

    Examples:
      | prefix   |
      | 'marc21' |
      | 'oai_dc' |
    
    # Unhappy path cases

  Scenario: check badArgument when get ListIdentifiers without metadataPrefix
    Given param verb = 'ListIdentifiers'
    And param set = 'all'
    When method GET
    Then status 400

  Scenario: check badArgument in ListIdentifiers with until is junk
    Given param verb = 'ListIdentifiers'
    And param until = 'junk'
    When method GET
    Then status 400

  Scenario: check badArgument in ListIdentifiers with from is junk
    Given param verb = 'ListIdentifiers'
    And param from = 'junk'
    When method GET
    Then status 400

  Scenario: check badArgument in ListIdentifiers with invalid resumptionToken
    Given param verb = 'ListIdentifiers'
    And param resumptionToken = 'junk'
    And param until = '2000-02-05'
    When method GET
    Then status 400