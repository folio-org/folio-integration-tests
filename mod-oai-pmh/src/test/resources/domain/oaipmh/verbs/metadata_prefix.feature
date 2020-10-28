Feature: tests for MetadataPrefix verb

  Background:
    * def pmhUrl = baseUrl + '/oai/records'
    * url pmhUrl

  Scenario: get ListMetadataFormats
    Given param verb = 'ListMetadataFormats'
    When method GET
    Then status 200
    Then match response //responseDate == checkDateByRegEx
    Then match response //metadataPrefix == ['marc21', 'oai_dc', 'marc21_withholdings']
    * match response count(//metadataFormat) == 3

  Scenario: check badArgument when get ListMetadataFormats with invalid identifier
    Given param verb = 'ListMetadataFormats'
    Given param identifier = 'invalid'
    When method GET
    Then status 400
    Then match response //responseDate == checkDateByRegEx
    Then match response //error == 'Identifier has invalid structure.'