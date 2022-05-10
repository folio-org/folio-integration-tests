Feature: edge-oai-pmh feature
  Background:
    * url edgeUrl

  Scenario:
    Given path 'oai', apikey
    And param verb = 'ListMetadataFormats'
    When method GET
    Then status 200