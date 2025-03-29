Feature: tests for GetRecord verb

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl

  # Happy path cases

  Scenario Outline: get GetRecord request <prefix>
    Given param verb = 'GetRecord'
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

  Scenario Outline: check badArgument in GetRecord request without identifier <prefix>
    And param verb = 'GetRecord'
    And param metadataPrefix = <prefix>
    When method GET
    Then status 400

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |

  Scenario Outline: check badArgument in GetRecord request with invalid identifier <prefix>
    Given param verb = 'GetRecord'
    And param identifier = 'invalid'
    And param metadataPrefix = <prefix>
    When method GET
    Then status 400

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |

  Scenario: check badArgument in GetRecord request without metadataPrefix
    Given param verb = 'GetRecord'
    And param identifier = 'oai:folio.org:' + testUser.tenant + '/54cc0262-76df-4cac-acca-b10e9bc5c79a'
    When method GET
    Then status 400

  Scenario Outline: check idDoesNotExist error in GetRecord request <prefix>
    Given param verb = 'GetRecord'
    And param identifier = 'oai:folio.org:' + testUser.tenant + '/777be1ac-5073-44cc-9925-a6b8955f4a75'
    And param metadataPrefix = <prefix>
    When method GET
    Then status 404

    Examples:
      | prefix                |
      | 'marc21'              |
      | 'oai_dc'              |

    #OAI-PMH is accepting GET only, POST test is for EDGE
  Scenario Outline: post GetRecord with empty json <prefix>
    Given param verb = 'GetRecord'
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