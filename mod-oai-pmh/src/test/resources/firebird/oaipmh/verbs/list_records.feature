Feature: tests for ListRecords verb

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl

  Scenario Outline: get ListRecords <prefix>
    Given param verb = 'ListRecords'
    And param metadataPrefix = <prefix>
    When method GET
    Then status 200
    Then match response //responseDate == checkDateByRegEx

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |

  Scenario Outline: get ListRecords with from and until <prefix>
    Given param verb = 'ListRecords'
    And param metadataPrefix = <prefix>
    * def currentOnlyDate = function(){return java.time.LocalDateTime.now(java.time.ZoneOffset.UTC).format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd"))}
    And param from = currentOnlyDate()
    And param until = currentOnlyDate()
    When method GET
    Then status 200
    * match response count(//identifier) == 10

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |

  Scenario Outline: check badArgument in ListRecords with invalid from <prefix>
    Given param verb = 'ListRecords'
    And param metadataPrefix = <prefix>
    And param from = 'junk'
    When method GET
    Then status 400

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |

  Scenario: check badResumptionToken error
    Given param verb = 'ListRecords'
    And param resumptionToken = 'bWV0YWRhdGFQcmVmaXg9bWFyYzIxJmZyb209MjAyMC0wNC0wOVQxMjoyMjowMFomdW50aWw9MjAyMC0wNC0xMFQxMToyNTo0NlomdG90YWxSZWNvcmRzPTE5MTQzJm9mZnNldD0yMDAmbmV4dFJlY29yZElkPWM5NjRlZmVjLWMxYzAtNDMwZC1iMzE5LTk1OWIyNjE5NGM0ZiZsaW1pdD0xMDAw'
    When method GET
    Then status 400

  Scenario Outline: check badArgument in ListRecords with invalid resumptionToken <prefix>
    Given param verb = 'ListRecords'
    And param resumptionToken = 'junk'
    And param metadataPrefix = <prefix>
    When method GET
    Then status 400

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |

  Scenario Outline: check badArgument in ListRecords with invalid until <prefix>
    Given param verb = 'ListRecords'
    And param metadataPrefix = <prefix>
    And param until = 'junk'
    When method GET
    Then status 400

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |

    #Checking for version 2.0 specific exceptions

  Scenario Outline: check badArgument in ListRecords with invalid format date <prefix>
    Given param verb = 'ListRecords'
    And param metadataPrefix = <prefix>
    And param from = '2002-02-05'
    And param until = '2002-02-06T05:35:00Z'
    When method GET
    Then status 400

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |

  Scenario Outline: check noRecordsMatch in ListRecords request <prefix>
    Given param verb = 'ListRecords'
    And param metadataPrefix = <prefix>
    And param until = '1969-01-01T00:00:00Z'
    When method GET
    Then status 404

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |