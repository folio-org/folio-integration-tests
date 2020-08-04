Feature: oai-pmh basic tests
  #
  # Tests according to http://www.openarchives.org/Register/ValidateSite
  #

  Background:
    * def pmhUrl = baseUrl +'/oai/records'
    * url pmhUrl
    * def checkDateByRegEx = '#regex \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z'
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'text/xml', 'x-okapi-token': '#(okapitoken)', 'x-okapi-tenant': '#(testUser.tenant)' }

  # TestRailID: C11150
  Scenario Outline: get ListRecords <prefix>
    And param verb = 'ListRecords'
    And param metadataPrefix = <prefix>
    When method GET
    Then status 200
    Then match response //responseDate == checkDateByRegEx

    Examples:
    | prefix                |
    | 'marc21'              |
    | 'oai_dc'              |

  Scenario Outline: get ListRecords with from and until <prefix>
    And param verb = 'ListRecords'
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

  Scenario Outline: get ListIdentifiers <prefix>
    And param verb = 'ListIdentifiers'
    And param metadataPrefix = <prefix>
    And param set = 'all'
    When method GET
    Then status 200
    Then match response //responseDate == checkDateByRegEx
    * match response count(//header) == 10

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |

  Scenario: get ListSets
    And param verb = 'ListSets'
    When method GET
    Then status 200
    Then match response //responseDate == checkDateByRegEx
    Then match response //setSpec == 'all'
    * match response count(//set) == 1

  Scenario: get Identify
    And param verb = 'Identify'
    When method GET
    Then status 200
    Then match response //protocolVersion == '2.0'
    Then match response //granularity == 'YYYY-MM-DDThh:mm:ssZ'
    Then match response //earliestDatestamp == '1970-01-01T00:00:00Z'

  Scenario: get ListMetadataFormats
    And param verb = 'ListMetadataFormats'
    When method GET
    Then status 200
    Then match response //responseDate == checkDateByRegEx
    Then match response //metadataPrefix == ['marc21', 'oai_dc', 'marc21_withholdings']
    * match response count(//metadataFormat) == 3

  Scenario Outline: get GetRecord request <prefix>
    And param verb = 'GetRecord'
    And param identifier = 'oai:folio.org:' + testUser.tenant + '/6b4ae089-e1ee-431f-af83-e1133f8e3da0'
    And param metadataPrefix = <prefix>
    When method GET
    Then status 200
    Then match response //responseDate == checkDateByRegEx
    Then match response //setSpec == 'all'

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |

    # Unhappy path cases

  Scenario: check badVerb error
    And param verb = 'junk'
    When method GET
    Then status 400

  Scenario: check badVerb error with only parameter junk
    And param junk = 'junk'
    When method GET
    Then status 400

  Scenario: check badArgument error
    And param verb = 'ListRecord'
    When method GET
    Then status 400

  Scenario Outline: check badArgument in GetRecord request without identifier <prefix>
    And param verb = 'GetRecord'
    And param metadataPrefix = <prefix>
    When method GET
    Then status 400

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |

  Scenario: check badArgument in GetRecord request with identifier but without metadataPrefix
    And param verb = 'GetRecord'
    And param identifier = 'oai:folio.org:' + testUser.tenant + '/54cc0262-76df-4cac-acca-b10e9bc5c79a'
    When method GET
    Then status 400

  Scenario Outline: check badArgument in GetRecord request with invalid identifier <prefix>
    And param verb = 'GetRecord'
    And param identifier = 'invalid'
    And param metadataPrefix = <prefix>
    When method GET
    Then status 400

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |

  Scenario: check badArgument in ListIdentifiers with until is junk
    And param verb = 'ListIdentifiers'
    And param until = 'junk'
    When method GET
    Then status 400

  Scenario: check badArgument in ListIdentifiers with from is junk
    And param verb = 'ListIdentifiers'
    And param from = 'junk'
    When method GET
    Then status 400

  Scenario: check badArgument in ListIdentifiers with invalid resumptionToken
    And param verb = 'ListIdentifiers'
    And param resumptionToken = 'junk'
    And param until = '2000-02-05'
    When method GET
    Then status 400

  Scenario Outline: check badArgument in ListRecords with invalid from <prefix>
    And param verb = 'ListRecords'
    And param metadataPrefix = <prefix>
    And param from = 'junk'
    When method GET
    Then status 400

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |

  Scenario: check badResumptionToken error
    And param verb = 'ListRecords'
    And param resumptionToken = 'bWV0YWRhdGFQcmVmaXg9bWFyYzIxJmZyb209MjAyMC0wNC0wOVQxMjoyMjowMFomdW50aWw9MjAyMC0wNC0xMFQxMToyNTo0NlomdG90YWxSZWNvcmRzPTE5MTQzJm9mZnNldD0yMDAmbmV4dFJlY29yZElkPWM5NjRlZmVjLWMxYzAtNDMwZC1iMzE5LTk1OWIyNjE5NGM0ZiZsaW1pdD0xMDAw'
    When method GET
    Then status 400

  Scenario Outline: check badArgument in ListRecords with invalid resumptionToken
    And param verb = 'ListRecords'
    And param resumptionToken = 'junk'
    And param metadataPrefix = <prefix>
    When method GET
    Then status 400

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |

  Scenario Outline: check badArgument in ListRecords with invalid until <prefix>
    And param verb = 'ListRecords'
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
    And param verb = 'ListRecords'
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
    And param verb = 'ListRecords'
    And param metadataPrefix = <prefix>
    And param until = '1969-01-01T00:00:00Z'
    When method GET
    Then status 404

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |

  Scenario Outline: check idDoesNotExist error in GetRecord request <prefix>
    And param verb = 'GetRecord'
    And param identifier = 'oai:folio.org:' + testUser.tenant + '/777be1ac-5073-44cc-9925-a6b8955f4a75'
    And param metadataPrefix = <prefix>
    When method GET
    Then status 404

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |

    #Checking that HTTP POST requests are handled correctly

  @Ignore
    #OAI-PMH is accepting GET only, POST test is for EDGE
  Scenario: post Identify with empty json
    And param verb = 'Identify'
    And request
    """
    {
    }
    """
    When method GET
    Then status 200
    Then match response //protocolVersion == '2.0'
    Then match response //granularity == 'YYYY-MM-DDThh:mm:ssZ'
    Then match response //earliestDatestamp == '1970-01-01T00:00:00Z'

  @Ignore
    #OAI-PMH is accepting GET only, POST test is for EDGE
  Scenario Outline: post GetRecord with empty json <prefix>
    And param verb = 'GetRecord'
    And param identifier = 'oai:folio.org:' + testUser.tenant + '/54cc0262-76df-4cac-acca-b10e9bc5c79a'
    And param metadataPrefix = <prefix>
    And request
     """
    {
    }
     """
    When method GET
    Then status 200
    Then match response //responseDate == checkDateByRegEx
    Then match response //setSpec == 'all'

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |
