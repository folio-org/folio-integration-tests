Feature: Mapping Metadata tests

  Background:
    * url baseUrl
    * callonce login testUser
    * configure headers = { 'Content-Type': 'application/json', 'x-okapi-token': '#(okapitoken)', 'Accept': 'application/json, text/plain' }


  Scenario: GET '/mapping-metadata/type/marc-bib' should return 200 and mapping metadata
    Given path '/mapping-metadata/type/marc-bib'
    When method GET
    Then status 200
    And match responseType == 'json'
    And match response.mappingRules contains '"target":"identifiers.identifierTypeId"'
    And json mappingParams = response.mappingParams
    And match mappingParams.linkingRules == '#present'


  Scenario: GET '/mapping-metadata/type/invalid-record-type' should return 400 with error message
    Given path '/mapping-metadata/type/invalid-record-type'
    When method GET
    Then status 400
    And match response == 'Only marc-bib, marc-holdings or marc-authority supported'