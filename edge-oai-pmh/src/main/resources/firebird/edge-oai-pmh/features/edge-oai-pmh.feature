Feature: edge-oai-pmh feature
  Background:
    * url edgeUrl

  Scenario:
    Given path 'oai', apikey
    And param metadataPrefix = 'marc21_withholdings'
    And param verb = 'ListRecords'
    When method GET
    Then status 200